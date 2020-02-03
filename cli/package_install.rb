# frozen_string_literal: true

command :'package:install' do
  desc 'Install a named helm package'

  option '-h', '--hippofile [RECIPE]', 'The path to the Hippofile (defaults: ./Hippofile)' do |value, options|
    options[:hippofile] = value.to_s
  end

  option '-p', '--package [NAME]', 'The name of the package to install' do |value, options|
    options[:package] = value
  end

  action do |context|
    require 'hippo/package'
    package, cli = Hippo::Package.setup_from_cli_context(context)
    cli.preflight

    if package.installed?
      puts "#{package.name} is already installed. You probably want to use helm:upgrade instead."
    else
      cli.apply_namespace
      cli.apply_config

      puts "Installing #{package.name} with Helm..."
      package.install
      puts "#{package.name} installed successfully"
    end
  end
end
