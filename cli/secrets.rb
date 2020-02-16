# frozen_string_literal: true

command :secrets do
  desc 'Create/edit an encrypted secrets file'

  action do |context|
    require 'hippo/cli'
    cli = Hippo::CLI.setup(context)
    cli.preflight

    manager = cli.stage.secret_manager
    unless manager.key_available?
      puts "\e[31mNo key has been published for this stage yet.\e[0m"
      puts "Use `hippo #{cli.stage.name} key --generate` to generate one."
      exit 2
    end

    manager.edit
  end
end
