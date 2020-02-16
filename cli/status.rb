# frozen_string_literal: true

command :status do
  desc 'Show current status of the namespace'

  option '--full', 'Include all relevant objects in namespace' do |_value, options|
    options[:full] = true
  end

  action do |context|
    require 'hippo/cli'
    cli = Hippo::CLI.setup(context)
    cli.preflight

    objects = %w[pods svc ingress deployments jobs statefulset]
    objects += %w[secret cm pvc networkpolicy] if context.options[:full]

    command = cli.stage.kubectl('get', objects.join(','))
    exec *command
  end
end
