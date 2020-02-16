# frozen_string_literal: true

command :kubectl do
  desc 'Execute kubectl commands with the correct namespace for the stage'

  action do |context|
    require 'hippo/cli'
    cli = Hippo::CLI.setup(context)
    cli.preflight

    ARGV.shift(2)
    ARGV.delete('--')
    exec cli.stage.kubectl(*ARGV).join(' ')
  end
end
