# frozen_string_literal: true

require 'liquid'
require 'hippo/util'

module Hippo
  class Kubernetes
    OBJECT_DIRECTORY_NAMES = %w[config deployments jobs/install jobs/deploy services].freeze

    include Hippo::Util

    def initialize(recipe, options)
      @recipe = recipe
      @options = options
    end

    # Load and return a set of objects from a given path.
    # Parse them through the templating and return them in the appropriate
    # context.
    #
    # @param stage [Hippo::Stage]
    # @param commit [String] the commit ref
    # @param path [String]
    # @return
    def objects(path, stage, commit)
      time = Time.now

      yamls = load_yaml_from_directory(path)
      yamls |= load_yaml_from_directory(File.join(path, stage.name))

      yamls.map do |yaml_part|
        object = yaml_part.parse(@recipe, stage, commit)

        # Unless a namespace has been specified in the metadata we will
        # want to add the namespace for the current stage.
        if object['metadata'].nil? || object['metadata']['namespace'].nil?
          object['metadata'] ||= {}
          object['metadata']['namespace'] = stage.namespace
        end

        # Add our own details to the metadata of all objets created by us so
        # we know where they came from.
        object['metadata']['annotations'] ||= {}
        object['metadata']['annotations']['hippo.adam.ac/builtAt'] ||= time.to_s
        object['metadata']['annotations']['hippo.adam.ac/builtBy'] ||= ENV['USER'] || 'unknown'

        # Add some information to Deployments to reflect the latest
        # information about this deployment.
        if object['kind'] == 'Deployment'
          object['metadata']['annotations']['hippo.adam.ac/deployID'] ||= time.to_i.to_s
          if commit
            object['metadata']['annotations']['hippo.adam.ac/commitRef'] ||= commit.objectish
            object['metadata']['annotations']['hippo.adam.ac/commitMessage'] ||= commit.message
          end

          if pod_metadata = object.dig('spec', 'template', 'metadata')
            pod_metadata['annotations'] ||= {}
            pod_metadata['annotations']['hippo.adam.ac/deployID'] ||= time.to_i.to_s
            if commit
              pod_metadata['annotations']['hippo.adam.ac/commitRef'] ||= commit.objectish
            end
          end
        end

        object
      end
    end

    # Apply the given configuration with kubectl
    #
    # @param config [Array<Hippo::YAMLPart>, String]
    # @return [void]
    def apply_with_kubectl(yaml_parts)
      unless yaml_parts.is_a?(String)
        yaml_parts = [yaml_parts] unless yaml_parts.is_a?(Array)
        yaml_parts = yaml_parts.map { |yp| yp.hash.to_yaml }.join("\n---\n")
      end

      Open3.popen3('kubectl apply -f -') do |stdin, stdout, stderr, wt|
        stdin.puts yaml_parts
        stdin.close

        stdout = stdout.read.strip
        stderr = stderr.read.strip

        if wt.value.success?
          puts stdout
          stdout.split("\n").each_with_object({}) do |line, hash|
            if line =~ %r{\A([\w\/\-\.]+) (\w+)\z}
              hash[Regexp.last_match(1)] = Regexp.last_match(2)
            end
          end
        else
          raise Error, "[kubectl] #{stderr}"
        end
      end
    end

    # Get details of objects using kubectl.
    #
    # @param stage [Hippo::Stage]
    # @param names [Array<String>]
    # @raises [Hippo::Error]
    # @return [Array<Hash>]
    def get_with_kubectl(stage, *names)
      command = [
        'kubectl',
        '-n', stage.namespace,
        'get',
        names,
        '-o', 'yaml'
      ].flatten.reject(&:nil?)

      Open3.popen3(*command) do |_, stdout, stderr, wt|
        if wt.value.success?
          yaml = YAML.safe_load(stdout.read, permitted_classes: [Time])
          yaml['items'] || [yaml]
        else
          raise Error, "[kutectl] #{stderr.read}"
        end
      end
    end

    # Delete a named job from the cluster
    #
    # @param stage [Hippo::Stage]
    # @param name [String]
    # @raises [Hippo::Error]
    # @return [void]
    def delete_job(stage, name)
      command = [
        'kubectl',
        '-n', stage.namespace,
        'delete',
        'job',
        name
      ]

      Open3.popen3(*command) do |_, stdout, stderr, wt|
        if wt.value.success?
          puts stdout.read
          true
        else
          stderr = stderr.read
          if stderr =~ /\"#{name}\" not found/
            false
          else
            raise Error, "[kutectl] #{stderr.read}"
          end
        end
      end
    end

    # Poll the named jobs and return them when all are complete
    # or the number of checks is exceeded.
    #
    # @param stage [Hippo::Stage]
    # @param names [Array<String>]
    # @param times [Integer]
    # @return [Array<Boolean, Array<Hash>]
    def wait_for_jobs(stage, names, times = 120)
      jobs = nil
      times.times do
        jobs = get_with_kubectl(stage, *names)

        # Are all the jobs completed?
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
