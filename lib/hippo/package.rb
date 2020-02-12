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
      run_install_command('upgrade', '--history-max', @options['max-revisions'] ? @options['max-revisions'].to_i.to_s : '5')
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

    def helm(*commands)
      command = ['helm']
      command += ['--kube-context', @stage.context] if @stage.context
      command += ['-n', @stage.namespace]
      command += commands
      command
    end

    private

    def install_command(verb, *additional)
      helm(verb, name, package, '-f', '-', *additional)
    end

    def run_install_command(verb, *additional)
      run(install_command(verb, *additional), stdin: final_values.to_yaml(line_width: -1))
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
