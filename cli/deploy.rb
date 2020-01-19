# frozen_string_literal: true

command :deploy do
  desc 'Deploy the application to Kubernetes (including image build/push)'

  option '-h', '--hippofile [RECIPE]', 'The path to the Hippofile (defaults: ./Hippofile)' do |value, options|
    options[:hippofile] = value.to_s
  end

  option '--no-upgrade', 'Do not run the upgrade jobs' do |_value, options|
    options[:upgrade] = false
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
    else
      steps.prepare_repository
      steps.build
      steps.publish
    end

    steps.apply_configuration
    steps.apply_secrets

    unless context.options[:upgrade] == false
      if steps.upgrade == false
        raise Hippo::Error, 'Not all jobs completed successfully. Cannot continue with deployment.'
      end
    end

    steps.apply_services
    steps.deploy
  end
end
