# frozen_string_literal: true

command :exec do
  desc 'Exec a command on a given pod'

  action do |context|
    require 'hippo/cli'
    cli = Hippo::CLI.setup(context)
    cli.preflight

    command = context.args[2]
    if command.nil?
      raise Error, 'Must specify command alias as first argument after `exec`'
    end

    command = cli.stage.command(command)
    raise Error, "Invalid command alias `#{context.args[2]}`" if command.nil?

    command_to_run = ([command[:command]] + context.args[3..-1]).join(' ')

    exec cli.stage.kubectl("exec -it #{command[:target]} -- #{command_to_run}").join(' ')
  end
end
