# frozen_string_literal: true

command :'apply-config' do
  desc 'Apply configuration'

  option '-s', '--stage [STAGE]', 'The name of the stage' do |value, options|
    options[:stage] = value.to_s
  end

  option '-h', '--hippofile [RECIPE]', 'The path to the Hippofile (defaults: ./Hippofile)' do |value, options|
    options[:hippofile] = value.to_s
  end

  action do |context|
    require 'hippo/cli_steps'
    steps = Hippo::CLISteps.setup(context)
    steps.apply_config
    steps.apply_secrets
  end
end
