# frozen_string_literal: true

require 'yaml'
require 'hippo/build_spec'
require 'hippo/error'
require 'hippo/kubernetes'
require 'hippo/repository'
require 'hippo/stage'
require 'hippo/util'

module Hippo
  class Recipe
    include Util

    class RecipeNotFound < Error
    end

    class << self
      # Load a new Recipe class from a given file.
      #
      # @param path [String] path to recipe file.
      # @return [Hippo::Recipe]
      def load_from_file(path)
        unless File.file?(path)
          raise RecipeNotFound, "No recipe file found at #{path}"
        end

        hash = YAML.load_file(path)
        new(hash, path)
      end
    end

    # @param hash [Hash] the raw hash from the underlying yaml file
    def initialize(hash, hippofile_path = nil)
      @hash = hash
      @hippofile_path = hippofile_path
    end

    attr_reader :path

    # Return the root directory where the Hippofile is located
    #
    def root
      File.dirname(@hippofile_path)
    end

    # Return the repository that this manifest should be working with
    #
    # @return [Hippo::Repository]
    def repository
      return unless @hash['repository']

      @repository ||= Repository.new(@hash['repository'])
    end

    # Return the app name
    #
    # @return [String, nil]
    def name
      @hash['name']
    end

    # Return kubernetes configuration
    #
    # @return [Hippo::Kubernetes]
    def kubernetes
      @kubernetes ||= Kubernetes.new(self, @hash['kubernetes'] || {})
    end

    # Return the stages for this recipe
    #
    # @return [Hash<Hippo::Stage>]
    def stages
      @stages ||= begin
        yamls = load_yaml_from_directory(File.join(root, 'stages'))
        yamls.each_with_object({}) do |yaml, hash|
          stage = Stage.new(yaml)
          hash[stage.name] = stage
        end
      end
    end

    # Return the builds for this recipe
    #
    # @return [Hash<Hippo::BuildSpec>]
    def build_specs
      @build_specs ||= @hash['builds'].each_with_object({}) do |(key, options), hash|
        hash[key] = BuildSpec.new(self, key, options)
      end
    end

    # Return configuration
    #
    # @return []
    def console
      @hash['console']
    end

    # Return the template variables that should be exposed
    #
    # @return [Hash]
    def template_vars
      {
        'repository' => repository ? repository.template_vars : nil,
        'builds' => build_specs.each_with_object({}) { |(_, bs), h| h[bs.name] = bs.template_vars }
      }
    end

    # Parse a string through the template parser
    #
    # @param string [String]
    # @return [String]
    def parse(stage, commit, string)
      template = Liquid::Template.parse(string)
      template_variables = template_vars
      template_variables['stage'] = stage.template_vars
      if commit
        template_variables['commit'] = {
          'ref' => commit.objectish,
          'message' => commit.message
        }
      end
      template.render(template_variables)
    end
  end
end
