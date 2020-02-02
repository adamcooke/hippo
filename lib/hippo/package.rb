# frozen_string_literal: true

require 'hippo/cli'
require 'hippo/extensions'

module Hippo
  class Package
    def initialize(options, stage)
      @options = options
      @stage = stage
    end

    # Return the name of the package (i.e. the release name)
    # and how this package will be referred.
    #
    # @return [String]
    def name
      @options['name']
    end

    # Return the name of the package to be installed.
    # Including the registry.
    #
    # @return [String]
    def package
      @options['package']
    end

    # return values defined in the package's manifest file
    #
    # @return [Hash]
    def values
      @options['values']
    end

    # Compile a set of final values which should be used when
    # upgrading and installing this package.
    #
    # @return [Hash]
    def final_values
      overrides = @stage.overridden_package_values[name]
      values.deep_merge(overrides)
    end

    # Install this package
    #
    # @return [void]
    def install
      run_install_command('install')
    end

    # Upgrade this package
    #
    # @return [void]
    def upgrade
      run_install_command('upgrade', '--history-max', '5')
    end

    # Uninstall this packgae
    #
    # @return [void]
    def uninstall
      run(helm('uninstall', name))
    end

    # Is this release currently installed for the stage?
    #
    # @return [Boolean]
    def installed?
      secrets = @stage.get('secrets').map(&:name)
      secrets.any? { |s| s.match(/\Ash\.helm\.release\.v\d+\.#{Regexp.escape(name)}\./) }
    end

    # Return the notes for this package
    #
    # @return [String]
    def notes
      run(helm('get', 'notes', name))
    end

    # Return an array of variables which should be exported
    # to the templating engine.
    #
    # @return [Hash]
    def template_vars
      return {} unless @options['vars'].is_a?(Hash)

      @options['vars'].each_with_object({}) do |(key, value), hash|
        if value.is_a?(Hash) && fs = value['fromSecret']
          secret = @stage.get('secret', fs['secretName']).first || {}
          secret = secret.dig('data', fs['key'])
          secret = Base64.decode64(secret) if secret
          hash[key] = secret
        else
          hash[key] = value.to_s
        end
      end
    end

    private

    def helm(*commands)
      command = ['helm']
      command += ['--kube-context', @stage.context] if @stage.context
      command += ['-n', @stage.namespace]
      command += commands
      command
    end

    def install_command(verb, *additional)
      helm(verb, name, package, '-f', '-', *additional)
    end

    def run_install_command(verb, *additional)
      run(install_command(verb, *additional), stdin: final_values.to_yaml)
      true
    end

    def run(command, stdin: nil)
      stdout, stderr, status = Open3.capture3(*command, stdin_data: stdin)
      raise Error, "[helm] #{stderr}" unless status.success?

      stdout
    end

    class << self
      def setup_from_cli_context(context)
        cli = Hippo::CLI.setup(context)
        package_name = context.options[:package]
        if package_name.nil? || package_name.empty?
          raise Error, 'A package name must be provided in -p or --package'
        end

        package = cli.stage.packages[package_name]
        if package.nil?
          raise Error, "No package named '#{package_name}' has been defined"
        end

        [package, cli]
      end
    end
  end
end
