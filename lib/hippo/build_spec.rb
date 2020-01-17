# frozen_string_literal: true

module Hippo
  class BuildSpec
    attr_reader :name

    def initialize(recipe, name, options)
      @recipe = recipe
      @name = name
      @options = options
    end

    def dockerfile
      @options['dockerfile'] || 'Dockerfile'
    end

    def image_name
      @options['image-name']
    end

    def image_name_for_commit(commit_ref)
      "#{image_name}:#{commit_ref}"
    end

    def template_vars
      {
        'dockerfile' => dockerfile,
        'image-name' => image_name
      }
    end
  end
end
