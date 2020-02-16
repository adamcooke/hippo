# frozen_string_literal: true

command :key do
  desc 'Display/generate details about the secret encryption key'

  option '-g', '--generate', 'Generate a new key' do |_value, options|
    options[:generate] = true
  end

  action do |context|
    require 'hippo/cli'
    cli = Hippo::CLI.setup(context)
    cli.preflight

    sm = cli.stage.secret_manager
    if sm.key_available?
      puts 'Secret encryption key is stored in secret/hippo-secret-key.'
    else
      if context.options[:generate]
        sm.create_key
        puts 'Secret encryption key has been generated and stored in secret/hippo-secret-key.'
      else
        puts 'Secret encryption key has not been generated yet.'
        puts 'Generate a new using:'
        puts
        puts "     hippo #{cli.stage.name} key --generate"
        puts
      end
    end
  end
end
