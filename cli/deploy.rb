# frozen_string_literal: true

command :deploy do
  desc 'Deploy the application to Kubernetes (including image build/push)'

  option '-h', '--hippofile [RECIPE]', 'The path to the Hippofile (defaults: ./Hippofile)' do |value, options|
    options[:hippofile] = value.to_s
  end

  option '--no-jobs', 'Do not run the deploy jobs' do |_value, options|
    options[:jobs] = false
  end

  option '--no-build', 'Do not build the images' do |_value, options|
    options[:build] = false
  end

  action do |context|
    require 'hippo/cli_steps'
    steps = Hippo::CLISteps.setup(context)
    if context.options[:build] == false
      commit = steps.recipe.repository.commit_for_branch(steps.stage.branch)
      puts 'Not building an image and just hoping one exists for current commit.'
      puts "Using #{commit.objectish} from #{steps.stage.branch}"
      steps.prepare_repository(fetch: false)
    else
      steps.prepare_repository
      steps.build
      steps.publish
    end

    steps.apply_namespace
    steps.apply_config
    steps.apply_secrets

    unless context.options[:jobs] == false
      if steps.run_deploy_jobs == false
        raise Hippo::Error, 'Not all jobs completed successfully. Cannot continue with deployment.'
      end
    end

    steps.apply_services
    steps.deploy
  end
end
