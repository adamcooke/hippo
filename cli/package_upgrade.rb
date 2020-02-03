# frozen_string_literal: true

command :'package:upgrade' do
  desc 'Upgrade a package'

  option '-h', '--hippofile [RECIPE]', 'The path to the Hippofile (defaults: ./Hippofile)' do |value, options|
    options[:hippofile] = value.to_s
  end

  option '-p', '--package [NAME]', 'The name of the package' do |value, options|
    options[:package] = value
  end

  action do |context|
    require 'hippo/package'
    package, cli = Hippo::Package.setup_from_cli_context(context)
    cli.preflight

    if package.installed?
      cli.apply_namespace
      cli.apply_config

      puts "Upgrading #{package.name} with Helm..."
      package.upgrade
      puts "#{package.name} upgraded successfully"
    else
      puts "#{package.name} is not installed. You probably want to use package:install first."
    end
  end
end
