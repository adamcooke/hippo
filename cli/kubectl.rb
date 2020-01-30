# frozen_string_literal: true

command :kubectl do
  desc 'Execute kubectl commands with the correct namespace for the stage'

  option '-h', '--hippofile [RECIPE]', 'The path to the Hippofile (defaults: ./Hippofile)' do |value, options|
    options[:hippofile] = value.to_s
  end

  action do |context|
    require 'hippo/cli'
    cli = Hippo::CLI.setup(context)
    ARGV.shift(2)
    ARGV.delete('--')
    exec cli.stage.kubectl(*ARGV).join(' ')
  end
end
