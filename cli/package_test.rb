# frozen_string_literal: true

command :'package:test' do
  desc 'Test a package installation'

  option '-p', '--package [NAME]', 'The name of the package' do |value, options|
    options[:package] = value
  end

  action do |context|
    require 'hippo/package'
    package, cli = Hippo::Package.setup_from_cli_context(context)
    cli.preflight

    exec(*package.helm('test', package.name, '--logs'))
  end
end
