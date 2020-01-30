# frozen_string_literal: true

command :'secrets:key' do
  desc 'Display/generate details about the secret encryption key'

  action do |context|
    require 'hippo/cli'
    cli = Hippo::CLI.setup(context)
    sm = cli.stage.secret_manager
    if sm.key_available?
      puts 'Secret encryption key is stored in secret/hippo-secret-key.'
    else
      puts 'Secret encryption key has not been generated yet.'
      puts 'Generate a new using:'
      puts
      puts "     hippo #{cli.stage.name} secrets:key --generate"
      puts
    end
  end
end
