# frozen_string_literal: true

module Hippo
  class YAMLPart
    attr_reader :yaml

    def initialize(yaml, path, index)
      @yaml = yaml.strip
      @path = path
      @index = index
    end

    def hash
      @hash ||= YAML.safe_load(@yaml)
    rescue Psych::SyntaxError => e
      raise Error, "YAML parsing error in #{@path} (index #{@index}) (#{e.message})"
    end

    def dig(*args)
      hash.dig(*args)
    end

    def [](name)
      hash[name]
    end

    def parse(recipe, stage, commit)
      template = Liquid::Template.parse(@yaml)
      template_variables = recipe.template_vars
      template_variables['stage'] = stage.template_vars
      if commit
        template_variables['commit'] = {
          'ref' => commit.objectish,
          'message' => commit.message
        }
      end
      parsed_part = template.render(template_variables)

      self.class.new(parsed_part, @path, @index)
    end
  end
end
