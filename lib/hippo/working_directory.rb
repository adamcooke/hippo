# frozen_string_literal: true

require 'hippo/manifest'
require 'hippo/util'
require 'hippo/error'

module Hippo
  class WorkingDirectory
    attr_reader :root

    def initialize(root = FileUtils.pwd)
      @root = root
    end

    # Return the path to the config file in this working directory
    #
    # @return [String]
    def config_path
      File.join(@root, 'manifest.yaml')
    end

    # Return the path to the local config file
    #
    # @return [String]
    def local_config_path
      File.join(@root, 'manifest.local.yaml')
    end

    # Return all the options configured in this working directory
    #
    # @return [Hash]
    def options
      return @options if @options

      if File.file?(config_path)
        @options = YAML.load_file(config_path)
        if File.file?(local_config_path)
          @options = @options.deep_merge(YAML.load_file(local_config_path))
        end
        @options
      else
        raise Error, "No manifest config file found at #{config_path}"
      end
    end

    # Return the manifest objet for this working directory
    #
    # @return [Hippo::Manifest]
    def manifest(update: true)
      if update && !@updated_manifest
        update_from_remote if can_update?
        @updated_manifest = true
      end

      raise Error, 'No manifest path could be determined' if manifest_path.nil?

      @manifest ||= Manifest.load_from_file(File.join(manifest_path, 'Hippofile'))
    end

    # Return the path to the manifest directory
    #
    # @return [String]
    def manifest_path
      case source_type
      when 'local'
        options.dig('source', 'localOptions', 'path')
      when 'remote'
        path = [remote_path] if remote_path
        File.join(remote_root_path, *path)
      else
        raise Error, "Invalid source.type ('#{source_type}')"
      end
    end

    # Return the type of manifest
    #
    # @return [String]
    def source_type
      options.dig('source', 'type')
    end

    # Return the path on the local filesystem that the remote repository
    # should be stored in.
    #
    # @return [String]
    def remote_root_path
      repo_ref = Digest::SHA1.hexdigest([remote_repository, remote_branch].join('---'))
      File.join(Hippo.tmp_root, 'manifests', repo_ref)
    end

    # Return the branch to use from the remote repository
    #
    # @return [String]
    def remote_branch
      options.dig('source', 'remoteOptions', 'branch') || 'master'
    end

    # Return the URL to the remote repository
    #
    # @return [String]
    def remote_repository
      options.dig('source', 'remoteOptions', 'repository')
    end

    # Return the path within the remote repository that we wish to work
    # with.
    #
    # @return [String]
    def remote_path
      options.dig('source', 'remoteOptions', 'path')
    end

    # Update the local cached copy of the manifest from the remote
    #
    # @return [Boolean]
    def update_from_remote(verbose: false)
      return false unless source_type == 'remote'

      Util.action "Updating manifest from #{remote_repository}..." do
        if File.directory?(remote_root_path)
          Util.system("git -C #{remote_root_path} fetch")
        else
          FileUtils.mkdir_p(File.dirname(remote_root_path))
          Util.system("git clone #{remote_repository} #{remote_root_path}")
        end

        Util.system("git -C #{remote_root_path} checkout origin/#{remote_branch}")
        File.open(update_timestamp_path, 'w') { |f| f.write(Time.now.to_i.to_s + "\n") }
      end

      if verbose
        puts
        puts "  Repository....: \e[33m#{wd.remote_repository}\e[0m"
        puts "  Branch........: \e[33m#{wd.remote_branch}\e[0m"
        puts "  Path..........: \e[33m#{wd.remote_path}\e[0m"
        puts
      end

      true
    end

    # Return the time this manifest was last updated
    #
    # @return [Time, nil]
    def last_updated_at
      if File.file?(update_timestamp_path)
        timestamp = File.read(update_timestamp_path)
        Time.at(timestamp.strip.to_i)
      end
    end

    # Return the path to the file where the last updated timestamp
    # is stored
    #
    # @return [String]
    def update_timestamp_path
      File.join(remote_root_path + '.uptime-timestamp')
    end

    # Can this working directory be updated?
    #
    # @return [Boolean]
    def can_update?
      source_type == 'remote'
    end

    # Load all stages that are available in this working directory
    #
    # @return [Hash<Symbol, Hippo::Stage>]
    def stages
      objects = Util.load_objects_from_path(File.join(@root, '**', 'config.{yml,yaml}'))
      objects.each_with_object({}) do |(path, objects), hash|
        objects.each do |obj|
          stage = Stage.new(self, File.dirname(path), obj)
          hash[stage.name] = stage
        end
      end
    end
  end
end
