# frozen_string_literal: true

command :secrets do
  desc 'View all secrets'

  option '-h', '--hippofile [RECIPE]', 'The path to the Hippofile (defaults: ./Hippofile)' do |value, options|
    options[:hippofile] = value.to_s
  end

  option '-s', '--stage [STAGE]', 'The name of the stage' do |value, options|
    options[:stage] = value.to_s
  end

  action do |context|
    require 'hippo/cli_steps'
    cli = Hippo::CLISteps.setup(context)

    require 'hippo/secret_manager'
    manager = Hippo::SecretManager.new(cli.recipe, cli.stage)
    unless manager.key_available?
      puts "\e[31mNo key has been published for this stage yet.\e[0m"
      exit 2
    end

    puts manager.secrets.map(&:to_editable_yaml)
  end
end
