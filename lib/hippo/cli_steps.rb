# frozen_string_literal: true

require 'open3'
require 'hippo/error'
require 'hippo/recipe'

module Hippo
  class CLISteps
    attr_reader :recipe
    attr_reader :stage

    def initialize(recipe, stage)
      @recipe = recipe
      @stage = stage
    end

    # Prepare the repository for this build by getting the latest
    # version from the remote and checking out the branch.
    def prepare_repository(fetch: false)
      info "Using repository #{@recipe.repository.url}"
      if fetch
        if @recipe.repository.cloned?
          info 'Repository is already cloned'
          action 'Fetching the latest repository data...'
          @recipe.repository.fetch
        else
          info 'Repository is not yet cloned.'
          action 'Cloning repository...'
          @recipe.repository.clone
        end

      elsif !fetch && !@recipe.repository.cloned?
        raise Error, 'Repository is not cloned yet so cannot continue'
      else
        info 'Not fetching latest repository, using cached copy'
      end

      action "Checking out '#{@stage.branch}' branch..."
      @recipe.repository.checkout(@stage.branch)
      @commit = @recipe.repository.commit
      info "Latest commit on branch is #{@commit.objectish}"
      info "Message: #{@commit.message.split("\n").first}"
    end

    def build
      if @commit.nil?
        raise Error, 'You cannot build without first preparing the repository'
      end

      Dir.chdir(@recipe.repository.path) do
        @recipe.build_specs.each do |_, build_spec|
          if build_spec.image_name.nil?
            raise Error, "No image-name has been specified for build #{build_spec.name}"
          end

          image_name = build_spec.image_name_for_commit(@commit)
          action "Building #{build_spec.name} with tag #{image_name}"

          command = [
            'docker', 'build', '.',
            '-f', build_spec.dockerfile,
            '-t', image_name
          ]
          external_command do
            if system(*command)
              @built_commit = @commit
              success "Successfully built image #{build_spec.image_name} for #{build_spec.name}"
            else
              raise Error, "Image for #{build_spec.name} did not succeed. Check output and try again."
            end
          end
        end
      end
    end

    def publish
      if @built_commit.nil?
        raise Error, 'You cannot publish without first building the image'
      end

      Dir.chdir(@recipe.repository.path) do
        @recipe.build_specs.each do |_, build_spec|
          if build_spec.image_name.nil?
            raise Error, "No image-name has been specified for build #{build_spec.name}"
          end

          image_name = build_spec.image_name_for_commit(@built_commit.objectish)
          action "Publishing #{build_spec.name} with tag #{image_name}"

          command = ['docker', 'push', image_name]
          external_command do
            if system(*command)
              success "Successfully published image #{image_name} for #{build_spec.name}"
            else
              raise Error, "Image for #{build_spec.name} was not published successfully. Check output and try again."
            end
          end
        end
      end
    end

    def run_install_jobs
      run_jobs('install')
    end

    def run_deploy_jobs
      run_jobs('deploy')
    end

    def deploy
      action 'Applying deployments'
      deployments = @recipe.kubernetes.objects('deployments', @stage, @commit)

      if deployments.nil?
        info 'No deployments file configured. Not applying any deployments'
      end

      external_command do
        @recipe.kubernetes.apply_with_kubectl(deployments)
      end
      success 'Deployments applied successfully'
      puts 'You can watch the deployment progressing using the command below:'
      puts
      puts "  ⏰  #{@stage.kubectl('get pods --watch')}"
      deployments.each do |deployment|
        puts '  👩🏼‍💻  ' + @stage.kubectl("describe deployment #{deployment['metadata']['name']}")
      end
      puts
    end

    def apply_services
      action 'Applying services'
      objects = @recipe.kubernetes.objects('services', @stage, @commit)
      if objects.empty?
        info 'No services have been defined'
      else
        external_command do
          @recipe.kubernetes.apply_with_kubectl(objects)
        end
        success 'Services applied successfully'
      end
    end

    def apply_config
      action 'Applying configuration'
      objects = @recipe.kubernetes.objects("config/#{@stage.name}", @stage, @commit)
      if objects.empty?
        info 'No configuration files have been defined'
      else
        external_command do
          @recipe.kubernetes.apply_with_kubectl(objects)
        end
        success 'Configuration applied successfully'
      end
    end

    def apply_secrets
      require 'hippo/secret_manager'
      action 'Applying secrets'
      manager = SecretManager.new(@recipe, @stage)
      unless manager.key_available?
        error 'No secret encryption key was available. Not applying secrets.'
        return
      end

      yamls = manager.secrets.map(&:to_secret_yaml).join("---\n")
      external_command do
        @recipe.kubernetes.apply_with_kubectl(yamls)
      end
      success 'Secrets applicated successfully'
    end

    private

    def info(text)
      puts text
    end

    def success(text)
      puts "\e[32m#{text}\e[0m"
    end

    def action(text)
      puts "\e[33m#{text}\e[0m"
    end

    def error(text)
      puts "\e[31m#{text}\e[0m"
    end

    def external_command
      $stdout.print "\e[37m"
      yield
    ensure
      $stdout.print "\e[0m"
    end

    def run_jobs(type)
      objects = @recipe.kubernetes.objects("jobs/#{type}", @stage, @commit)
      if objects.empty?
        info "No #{type} jobs exist so not applying anything"
        return true
      end

      action "Applying #{type} job objects objects to Kubernetes"

      result = nil
      external_command do
        # Remove any previous jobs that might have been running before
        objects.each do |job|
          @recipe.kubernetes.delete_job(@stage, job['metadata']['name'])
        end

        result = @recipe.kubernetes.apply_with_kubectl(objects)
      end

      puts 'Waiting for all scheduled jobs to finish...'
      timeout, jobs = @recipe.kubernetes.wait_for_jobs(@stage, result.keys)
      success_jobs = []
      failed_jobs = []
      jobs.each do |job|
        if job['status']['succeeded']
          success_jobs << job
        else
          failed_jobs << job
        end
      end

      if success_jobs.size == jobs.size
        success 'All jobs completed successfully.'
        puts 'You can review the logs for these by running the commands below.'
        puts
        result = true
      else
        error 'Not all install jobs completed successfully.'
        puts 'You should review the logs for these using the commands below.'
        puts
        result = false
      end

      jobs.each do |job|
        icon = if job['status']['succeeded']
                 '✅'
               else
                 '❌'
               end
        puts "  #{icon}  " + @stage.kubectl("logs job/#{job['metadata']['name']}")
      end
      puts

      result
    end

    class << self
      def setup(context)
        recipe = Hippo::Recipe.load_from_file(context.options[:hippofile] || './Hippofile')

        stage_name = context.options[:stage] || recipe.default_stage
        if stage_name.nil?
          raise Error, 'Must pass a stage name as --stage (or -s) or define a default stage'
        end

        stage = recipe.stages[stage_name]
        if stage.nil?
          raise Error, "Invalid stage name `#{stage_name}`. Check this has been defined in in your stages directory with a matching name?"
        end

        new(recipe, stage)
      end
    end
  end
end
