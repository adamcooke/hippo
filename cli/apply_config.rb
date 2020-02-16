# frozen_string_literal: true

command :'apply-config' do
  desc 'Apply configuration'

  action do |context|
    require 'hippo/cli'
    cli = Hippo::CLI.setup(context)
    cli.preflight
    cli.apply_namespace
    cli.apply_config
  end
end
