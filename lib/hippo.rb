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

  # Return the current kubectl context
  #
  # @return [String]
  def self.current_kubectl_context
    stdout, stderr, status = Open3.capture3('kubectl config current-context')
    unless status.success?
      raise Error, 'Could not determine current kubectl context'
    end

    stdout.strip
  end

  # Path to store temp files
  #
  # @return [String]
  def self.tmp_root
    File.join(ENV['HOME'], '.hippo')
  end
end
