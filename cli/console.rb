# frozen_string_literal: true

command :console do
  desc 'Open a console based on the configuration'

  option '-h', '--hippofile [RECIPE]', 'The path to the Hippofile (defaults: ./Hippofile)' do |value, options|
    options[:hippofile] = value.to_s
  end

  option '-d', '--deployment [NAME]', 'The name of the deployment to use' do |value, options|
    options[:deployment] = value.to_s
  end

  option '-c', '--command [NAME]', 'The command to run' do |value, options|
    options[:command] = value.to_s
  end

  action do |context|
    require 'hippo/cli_steps'
    cli = Hippo::CLISteps.setup(context)

    if cli.recipe.console.nil?
      raise Error, 'No console configuration has been provided in Hippofile'
    end

    time = Time.now.to_i
    deployment_name = context.options[:deployment] || cli.recipe.console['deployment']
    command = context.options[:command] || cli.recipe.console['command'] || 'bash'
    exec cli.stage.kubectl("exec -it deployment/#{deployment_name} -- #{command}")
  end
end
