# frozen_string_literal: true

command :secret do
  desc 'Create/edit an encrypted secrets file'

  option '-s', '--stage [STAGE]', 'The name of the stage' do |value, options|
    options[:stage] = value.to_s
  end

  option '--create-key', 'Create a new encryption key if missing' do |_value, options|
    options[:create_key] = true
  end

  action do |context|
    require 'hippo/cli_steps'
    steps = Hippo::CLISteps.setup(context)

    secret_name = context.args[0]
    raise Hippo::Error, 'You must provide a secret name' if secret_name.nil?

    require 'hippo/secret_manager'
    manager = Hippo::SecretManager.new(steps.recipe, steps.stage)
    if !manager.key_available? && context.options[:create_key]
      manager.create_key
    elsif !manager.key_available?
      puts "\e[31mNo key has been published for this stage yet. You can create"
      puts "a key automatically by adding --create-key to this command.\e[0m"
      exit 2
    elsif context.options[:create_key]
      puts "\e[31mThe --create-key option can only be provided when a key has not already"
      puts "been generated. Remove the key from the Kubernetes API to regenerate.\e[0m"
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
