# frozen_string_literal: true

command :console do
  desc 'Open a console based on the configuration'

  option '-d', '--deployment [NAME]', 'The name of the deployment to use' do |value, options|
    options[:deployment] = value.to_s
  end

  option '-c', '--command [NAME]', 'The command to run' do |value, options|
    options[:command] = value.to_s
  end

  action do |context|
    require 'hippo/cli'
    cli = Hippo::CLI.setup(context)

    if cli.manifest.console.nil?
      raise Error, 'No console configuration has been provided in Hippofile'
    end

    cli.preflight

    time = Time.now.to_i
    deployment_name = context.options[:deployment] || cli.manifest.console['deployment']
    command = context.options[:command] || cli.manifest.console['command'] || 'bash'
    exec cli.stage.kubectl("exec -it deployment/#{deployment_name} -- #{command}").join(' ')
  end
end
