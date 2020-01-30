# frozen_string_literal: true

require 'liquid'
require 'open3'
require 'hippo/secret_manager'

module Hippo
  class Stage
    attr_reader :manifest

    def initialize(manifest, options)
      @manifest = manifest
      @options = options
    end

    def name
      @options['name']
    end

    def branch
      @options['branch']
    end

    def namespace
      @options['namespace']
    end

    def context
      @options['context']
    end

    def vars
      @options['vars']
    end

    # These are the vars to represent this
    def template_vars
      {
        'name' => name,
        'branch' => branch,
        'namespace' => namespace,
        'context' => context,
        'images' => @manifest.images.values.each_with_object({}) { |image, hash| hash[image.name] = image.image_path_for_branch(branch) },
        'vars' => vars
      }
    end

    # Return a new decorator object that can be passed to objects that
    # would like to decorator things.
    def decorator
      proc do |data|
        template = Liquid::Template.parse(data)
        template.render(
          'stage' => template_vars,
          'manifest' => @manifest.template_vars
        )
      end
    end

    def objects(path)
      @manifest.objects(path, decorator: decorator)
    end

    def secret_manager
      @secret_manager ||= SecretManager.new(self)
    end

    # Return an array of all deployments for this stage
    #
    # @return [Hash<String,Hippo::ObjectDefinition>]
    def deployments
      Util.create_object_definitions(objects('deployments'), self, required_kinds: ['Deployment'])
    end

    # Return an array of all services/ingresses for this stage
    #
    # @return [Hash<String,Hippo::ObjectDefinition>]
    def services
      Util.create_object_definitions(objects('services'), self, required_kinds: %w[Service Ingress NetworkPolicy])
    end

    # Return an array of all configuration objects
    #
    # @return [Hash<String,Hippo::ObjectDefinition>]
    def configs
      Util.create_object_definitions(objects('config'), self)
    end

    # Return an array of all job objects
    #
    # @return [Hash<String,Hippo::ObjectDefinition>]
    def jobs(type)
      Util.create_object_definitions(objects("jobs/#{type}"), self)
    end

    # Return a kubectl command ready for use within this stage's
    # namespace and context
    #
    # @return [Array<String>]
    def kubectl(*commands)
      prefix = ['kubectl']
      prefix += ['--context', context] if context
      prefix += ['-n', namespace]
      prefix + commands
    end

    # Apply a series of objecst with
    #
    # @param objects [Array<Hippo::ObjectDefinition>]
    # @return [Hash]
    def apply(objects)
      yaml_to_apply = objects.map(&:yaml).join("\n")

      command = ['kubectl']
      command += ['--context', context] if context
      command += ['apply', '-f', '-']
      Open3.popen3(command.join(' ')) do |stdin, stdout, stderr, wt|
        stdin.puts yaml_to_apply
        stdin.close

        stdout = stdout.read.strip
        stderr = stderr.read.strip

        if wt.value.success?
          stdout.split("\n").each_with_object({}) do |line, hash|
            next unless line =~ %r{\A([\w\/\-\.]+) (\w+)\z}

            object = Regexp.last_match(1)
            status = Regexp.last_match(2)
            hash[object] = status

            status = "\e[32m#{status}\e[0m" unless status == 'unchanged'
            puts "\e[37m====> #{object} #{status}\e[0m"
          end
        else
          raise Error, "[kubectl] #{stderr}"
        end
      end
    end

    # Get some data from the kubernetes API
    #
    # @param names [Array<String>]
    # @return [Array<Hippo::ObjectDefinition>]
    def get(*names)
      command = kubectl('get', '-o', 'yaml', *names)
      Open3.popen3(*command) do |_, stdout, stderr, wt|
        raise Error, "[kutectl] #{stderr.read}" unless wt.value.success?

        yaml = YAML.safe_load(stdout.read, permitted_classes: [Time])
        yaml = yaml['items'] || [yaml]
        yaml.map { |y| ObjectDefinition.new(y, self, clean: true) }
      end
    end

    # Delete an object from the kubernetes API
    #
    # @param names [Array<String>]
    # @return [Boolean]
    def delete(*names)
      command = kubectl('delete', *names)
      Open3.popen3(*command) do |_, stdout, stderr, wt|
        if wt.value.success?
          stdout.read.split("\n").each do |line|
            puts "\e[37m====> #{line}\e[0m"
          end
          true
        else
          stderr = stderr.read
          if stderr =~ /\" not found$/
            false
          else
            raise Error, "[kutectl] #{stderr}"
          end
        end
      end
    end

    # Wait for the named jobs to complete
    def wait_for_jobs(names, times = 120)
      jobs = nil
      times.times do
        jobs = get(*names)

        if jobs.all? { |j| j['status']['active'].nil? }
          return [false, jobs]
        else
          sleep 2
        end
      end

      [true, jobs]
    end
  end
end
