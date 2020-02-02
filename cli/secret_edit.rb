# frozen_string_literal: true

command :'secret:edit' do
  desc 'Create/edit an encrypted secrets file'

  action do |context|
    require 'hippo/cli'
    cli = Hippo::CLI.setup(context)

    secret_name = context.args[0]
    raise Hippo::Error, 'You must provide a secret name' if secret_name.nil?

    manager = cli.stage.secret_manager
    unless manager.key_available?
      puts "\e[31mNo key has been published for this stage yet.\e[0m"
      puts "Use `hippo #{cli.stage.name} secret:key --generate` to generate one."
      exit 2
    end

    secret = manager.secret(secret_name)
    if secret.exists?
      secret.edit
    else
      puts "No secret exists at #{secret.path}. Would you like to create one?"
      response = STDIN.gets.strip.downcase.strip
      if %w[y yes please].include?(response)
        secret.create
        secret.edit
      else
        puts 'Not a problem. You can make it later.'
      end
    end
  end
end
