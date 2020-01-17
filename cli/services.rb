# frozen_string_literal: true

command :'apply-services' do
  desc 'Apply service configuration'

  option '-h', '--hippofile [RECIPE]', 'The path to the Hippofile (defaults: ./Hippofile)' do |value, options|
    options[:hippofile] = value.to_s
  end

  action do |context|
    require 'hippo/cli_steps'
    steps = Hippo::CLISteps.setup(context)
    steps.apply_services
  end
end
