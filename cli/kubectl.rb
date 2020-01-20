# frozen_string_literal: true

command :kubectl do
  desc 'Execute kubectl commands with the correct namespace for the stage'

  option '-s', '--stage [STAGE]', 'The name of the stage' do |value, options|
    options[:stage] = value.to_s
  end

  option '-h', '--hippofile [RECIPE]', 'The path to the Hippofile (defaults: ./Hippofile)' do |value, options|
    options[:hippofile] = value.to_s
  end

  action do |context|
    require 'hippo/cli_steps'
    cli = Hippo::CLISteps.setup(context)
    ARGV.shift
    exec cli.stage.kubectl(*ARGV)
  end
end
