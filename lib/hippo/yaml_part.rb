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

    def empty?
      @yaml.nil? ||
        @yaml.empty? ||
        hash.nil? ||
        hash.empty?
    end

    def to_yaml
      hash.to_yaml
    end

    def dig(*args)
      hash.dig(*args)
    end

    def [](name)
      hash[name]
    end

    def []=(name, value)
      hash[name] = value
    end

    def parse(recipe, stage, commit)
      parsed_part = recipe.parse(stage, commit, @yaml)
      self.class.new(parsed_part, @path, @index)
    end
  end
end
