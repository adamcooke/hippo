# frozen_string_literal: true

command :'package:uninstall' do
  desc 'Uninstall a package'

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
      puts "Uninstalling #{package.name} with Helm..."
      package.uninstall
      puts "#{package.name} uninstalled successfully"
    else
      puts "#{package.name} is not installed."
    end
  end
end
