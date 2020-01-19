# frozen_string_literal: true

command :logs do
  desc 'Print logs for a given deployment'

  option '-h', '--hippofile [RECIPE]', 'The path to the Hippofile (defaults: ./Hippofile)' do |value, options|
    options[:hippofile] = value.to_s
  end

  action do |context|
    require 'hippo/cli_steps'
    cli = Hippo::CLISteps.setup(context)
    exec cli.stage.kubectl('get pods,deployments,job,svc,ingress')
  end
end
