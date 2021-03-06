# frozen_string_literal: true

command :deploy do
  desc 'Deploy the application to Kubernetes (including image build/push)'

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
      if cli.run_deploy_jobs == false
        raise Hippo::Error, 'Not all jobs completed successfully. Cannot continue with deployment.'
      end
    end

    unless cli.deploy
      puts 'Deployment did not complete successfully. Not continuing any further.'
      exit 2
    end
    cli.apply_services
  end
end
