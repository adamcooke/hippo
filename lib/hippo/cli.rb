# frozen_string_literal: true

require 'securerandom'
require 'hippo/manifest'
require 'hippo/deployment_monitor'
require 'hippo/working_directory'

module Hippo
  class CLI
    attr_reader :wd
    attr_reader :stage

    # Initialize a new CLI instance
    #
    # @param wd [Hippo::WorkingDirectory]
    # @return [Hippo::CLI]
    def initialize(wd, stage)
      @wd = wd
      @stage = stage
    end

    def manifest
      wd.manifest
    end

    # Verify image existence
    #
    # @return [void]
    def verify_image_existence
      missing = 0
      stage.images.each do |_, image|
        if image.exists?
          puts "Image for #{image.name} exists at #{image.image_url}"
        else
          missing += 1
          puts "No #{image.name} image at #{image.image_url}"
        end
      end

      if missing > 0
        raise Error, "#{missing} #{missing == 1 ? 'image was' : 'images were'} not available. Cannot continue."
      end
    end

    # Run any checks that should be performed before running
    # any optionation which might influence the environment
    #
    # @return [void]
    def preflight
      if stage.context.nil?
        puts "\e[33mStage does not specify a context. The current context specified"
        puts "by the kubectl config will be used (#{Hippo.current_kubectl_context}).\e[0m"
        puts
        puts 'This is not recommended. Add a context name to your stage configuration.'
        puts
        exit 0 unless Util.confirm('Do you wish to continue?')
      end
    end

    # Apply the namespace configuration
    #
    # @return [void]
    def apply_namespace
      od = Hippo::ObjectDefinition.new(
        {
          'kind' => 'Namespace',
          'apiVersion' => 'v1',
          'metadata' => { 'name' => stage.namespace, 'labels' => { 'name' => stage.namespace } }
        },
        stage
      )
      apply([od], 'namespace')
    end

    # Apply all configuration and secrets
    #
    # @return [void]
    def apply_config
      apply(stage.configs, 'configuration')
    end

    # Install all packages
    #
    # @return [void]
    def install_all_packages
      if stage.packages.empty?
        puts 'There are no packages to install'
        return
      end

      stage.packages.values.each do |package|
        if package.installed?
          puts "#{package.name} is already installed. Upgrading..."
          package.upgrade
        else
          puts "Installing #{package.name} using Helm..."
          package.install
        end
      end

      puts "Finished with #{stage.packages.size} #{stage.packages.size == 1 ? 'package' : 'packages'}"
    end

    # Apply all services, ingresses and policies
    #
    # @return [void]
    def apply_services
      apply(stage.services, 'service')
    end

    # Run all deploy jobs
    #
    # @return [void]
    def run_deploy_jobs
      run_jobs('deploy')
    end

    # Run all install jobs
    #
    # @return [void]
    def run_install_jobs
      run_jobs('install')
    end

    # Run a full deployment
    #
    # @return [void]
    def deploy
      deployment_id = SecureRandom.hex(6)
      deployments = stage.deployments
      if deployments.empty?
        puts 'There are no deployment objects defined'
        return true
      end

      puts "Using deployment ID: #{deployment_id}"

      deployments.each do |deployment|
        deployment.insert_deployment_id!(deployment_id)
      end

      apply(deployments, 'deployment')
      puts 'Waiting for all deployments to roll out...'

      monitor = DeploymentMonitor.new(stage, deployment_id)
      monitor.on_success do |poll|
        if poll.replica_sets.size == 1
          puts "\e[32mDeployment rolled out successfully\e[0m"
        else
          puts "\e[32mAll #{poll.replica_sets.size} deployments all rolled out successfully\e[0m"
        end
      end

      monitor.on_wait do |poll|
        puts "Waiting for #{poll.pending.size} #{poll.pending.size == 1 ? 'deployment' : 'deployments'} (#{poll.pending_names.join(', ')})"
      end

      monitor.on_failure do |poll|
        puts "\e[31mLooks like things aren't going to plan with some deployments.\e[0m"
        puts 'You can review potential issues using the commads below:'

        poll.pending.each do |rs|
          puts
          name = rs.name.split('-').first
          puts "  hippo #{stage.name} kubectl -- describe deployment \e[35m#{name}\e[0m"
          puts "  hippo #{stage.name} kubectl -- logs deployment/\e[35m#{name}\e[0m --all-containers"
        end
        puts
      end

      monitor.wait
    end

    private

    def apply(objects, type)
      if objects.empty?
        puts "No #{type} objects found to apply"
      else
        puts "Applying #{objects.size} #{type} #{objects.size == 1 ? 'object' : 'objects'}"
        stage.apply(objects)
      end
    end

    def run_jobs(type)
      puts "Running #{type} jobs"
      jobs = stage.jobs(type)
      if jobs.empty?
        puts "There are no #{type} jobs to run"
        return true
      end

      jobs.each do |job|
        stage.delete('job', job.name)
      end

      applied_jobs = apply(jobs, 'deploy job')

      timeout, jobs = stage.wait_for_jobs(applied_jobs.keys)
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
        puts 'All jobs completed successfully'
        puts 'You can review the logs for these by running the commands below'
        puts
        result = true
      else
        puts "\e[31mNot all install jobs completed successfully.\e[0m"
        puts 'You should review the logs for these using the commands below'
        puts
        result = false
      end

      jobs.each do |job|
        icon = if job['status']['succeeded']
                 '✅'
               else
                 '❌'
               end
        puts "  #{icon}  hippo #{stage.name} kubectl -- logs job/#{job.name}"
      end
      puts
      result
    end

    class << self
      def setup(_context)
        wd = Hippo::WorkingDirectory.new

        stage = wd.stages[CURRENT_STAGE]
        if stage.nil?
          raise Error, "Invalid stage name `#{CURRENT_STAGE}`. Check this has been defined in in your stages directory with a matching name?"
        end

        new(wd, stage)
      end
    end
  end
end
