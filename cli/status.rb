# frozen_string_literal: true

command :status do
  desc 'Print status information from Kubernetes'

  option '-h', '--hippofile [RECIPE]', 'The path to the Hippofile (defaults: ./Hippofile)' do |value, options|
    options[:hippofile] = value.to_s
  end

  option '-s', '--stage [STAGE]', 'The name of the stage' do |value, options|
    options[:stage] = value.to_s
  end

  action do |context|
    require 'hippo/cli_steps'
    cli = Hippo::CLISteps.setup(context)
    exec cli.stage.kubectl('get pods,deployments,job,statefulset,pvc,svc,ingress')
  end
end
