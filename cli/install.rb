# frozen_string_literal: true

command :install do
  desc 'Run installation jobs for the application'

  option '-h', '--hippofile [RECIPE]', 'The path to the Hippofile (defaults: ./Hippofile)' do |value, options|
    options[:hippofile] = value.to_s
  end

  option '--no-build', 'Do not build the images' do |_value, options|
    options[:build] = false
  end

  option '--no-deploy', 'Do not deploy after install' do |_value, options|
    options[:deploy] = false
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

    if steps.install == false
      raise Hippo::Error, 'Not all installation jobs completed successfully. Cannot continue to deploy.'
    end

    unless context.options[:deploy] == false
      steps.apply_services
      steps.deploy
    end
  end
end
