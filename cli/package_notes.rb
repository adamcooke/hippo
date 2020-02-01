# frozen_string_literal: true

command :'package:notes' do
  desc 'Show notes about an installed Helm package'

  option '-h', '--hippofile [RECIPE]', 'The path to the Hippofile (defaults: ./Hippofile)' do |value, options|
    options[:hippofile] = value.to_s
  end

  option '-p', '--package [NAME]', 'The name of the package to install' do |value, options|
    options[:package] = value
  end

  action do |context|
    require 'hippo/package'
    package, = Hippo::Package.setup_from_cli_context(context)

    raise Error, "#{package.name} not installed" unless package.installed?

    puts package.notes
  end
end
