# frozen_string_literal: true

command :publish do
  desc 'Build and publish an image for the given stage'

  option '-h', '--hippofile [RECIPE]', 'The path to the Hippofile (defaults: ./Hippofile)' do |value, options|
    options[:hippofile] = value.to_s
  end

  action do |context|
    require 'hippo/cli_steps'
    steps = Hippo::CLISteps.setup(context)
    steps.prepare_repository
    steps.build
    steps.publish
  end
end
