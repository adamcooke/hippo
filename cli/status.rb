# frozen_string_literal: true

command :status do
  desc 'Show current status of the namespace'

  option '-h', '--hippofile [RECIPE]', 'The path to the Hippofile (defaults: ./Hippofile)' do |value, options|
    options[:hippofile] = value.to_s
  end

  action do |context|
    require 'hippo/cli'
    cli = Hippo::CLI.setup(context)

    command = cli.stage.kubectl('get', 'pods,svc,ingress,deployments,statefulset,cm,secret,pvc')
    exec *command
  end
end
