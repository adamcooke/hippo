# frozen_string_literal: true

module Hippo
  # The path where the user configuration file is stored
  CONFIG_PATH = File.join(ENV['HOME'], '.hippo', 'config.yaml')

  # Return the root to the gem
  #
  # @return [String]
  def self.root
    File.expand_path('../', __dir__)
  end

  # User the user configuration for Hippo
  #
  # @return [Hash]
  def self.config
    @config ||= begin
      if File.file?(CONFIG_PATH)
        YAML.load_file(CONFIG_PATH)
      else
        {}
      end
    end
  end
end
