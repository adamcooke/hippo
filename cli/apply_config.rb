# frozen_string_literal: true

command :'apply-config' do
  desc 'Apply configuration'

  option '-h', '--hippofile [RECIPE]', 'The path to the Hippofile (defaults: ./Hippofile)' do |value, options|
    options[:hippofile] = value.to_s
  end

  action do |context|
    require 'hippo/cli'
    cli = Hippo::CLI.setup(context)
    cli.preflight
    cli.apply_namespace
    cli.apply_config
  end
end
