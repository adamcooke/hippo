# frozen_string_literal: true

command :install do
  desc 'Run installation jobs for the application'

  option '-h', '--hippofile [RECIPE]', 'The path to the Hippofile (defaults: ./Hippofile)' do |value, options|
    options[:hippofile] = value.to_s
  end

  option '--no-deploy', 'Do not deploy after install' do |_value, options|
    options[:deploy] = false
  end

  option '--no-jobs', 'Do not run the deploy jobs' do |_value, options|
    options[:jobs] = false
  end

  action do |context|
    require 'hippo/cli'
    cli = Hippo::CLI.setup(context)
    cli.preflight

    cli.verify_image_existence

    cli.apply_namespace
    cli.apply_config

    unless context.options[:jobs] == false
      if cli.run_install_jobs == false
        raise Hippo::Error, 'Not all jobs completed successfully. Cannot continue with installation.'
      end
    end

    if context.options[:deploy] == false
      puts 'Not deploying because --no-deploy was specified'
      exit 0
    end

    unless cli.deploy
      puts 'Deployment did not complete successfully. Not continuing any further.'
      exit 2
    end
    cli.apply_services
  end
end
