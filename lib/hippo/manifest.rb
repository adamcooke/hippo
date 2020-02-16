# frozen_string_literal: true

require 'hippo/util'
require 'hippo/stage'
require 'hippo/image'

module Hippo
  class Manifest
    # Load a new manifest from a given Hippofile.
    #
    # @param path [String]
    # @return [Hippo::Manifest]
    class << self
      def load_from_file(path)
        unless File.file?(path)
          raise Error, "Hippofile file not found at #{path}"
        end

        root = File.dirname(path)
        new(Util.load_yaml_from_file(path).first, root)
      end
    end

    attr_reader :root

    def initialize(options, root)
      @options = options
      @root = File.expand_path(root)
    end

    def name
      @options['name'] || 'app'
    end

    def console
      @options['console']
    end

    def config
      @options['config'] || {}
    end

    def bootstrap
      @bootstrap ||= begin
        bootstrap_file = File.join(@root, 'bootstrap.yaml')
        if File.file?(bootstrap_file)
          YAML.load_file(bootstrap_file)
        else
          {}
        end
      end
    end

    def template_vars
      {
        'name' => name
      }
    end

    def images
      return {} unless @options['images'].is_a?(Hash)

      @options['images']
    end

    # Load all YAML objects at a given path and return them.
    #
    # @param path [String]
    # @param decorator [Proc] an optional parser to run across the raw YAML file
    # @return [Array<Hash>]
    def objects(path, decorator: nil)
      Util.load_objects_from_path(File.join(@root, path, '*.{yaml,yml}'), decorator: decorator)
    end
  end
end
