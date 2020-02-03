# frozen_string_literal: true

command :status do
  desc 'Show current status of the namespace'

  option '-h', '--hippofile [RECIPE]', 'The path to the Hippofile (defaults: ./Hippofile)' do |value, options|
    options[:hippofile] = value.to_s
  end

  option '--full', 'Include all relevant objects in namespace' do |_value, options|
    options[:full] = true
  end

  action do |context|
    require 'hippo/cli'
    cli = Hippo::CLI.setup(context)

    objects = %w[pods svc ingress deployments jobs statefulset]
    objects += %w[secret cm pvc networkpolicy] if context.options[:full]

    command = cli.stage.kubectl('get', objects.join(','))
    exec *command
  end
end
