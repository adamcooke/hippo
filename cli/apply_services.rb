# frozen_string_literal: true

command :'apply-services' do
  desc 'Apply service configuration'

  option '-s', '--stage [STAGE]', 'The name of the stage' do |value, options|
    options[:stage] = value.to_s
  end

  option '-h', '--hippofile [RECIPE]', 'The path to the Hippofile (defaults: ./Hippofile)' do |value, options|
    options[:hippofile] = value.to_s
  end

  action do |context|
    require 'hippo/cli_steps'
    steps = Hippo::CLISteps.setup(context)
    steps.apply_services
  end
end
