# frozen_string_literal: true

command :logs do
  desc 'Display logs for a particular pod'

  option '-h', '--hippofile [RECIPE]', 'The path to the Hippofile (defaults: ./Hippofile)' do |value, options|
    options[:hippofile] = value.to_s
  end

  option '-p', '--pod [POD]', 'The name of the pod' do |value, options|
    options[:pod] = value
  end

  option '-f', '--follow', 'Follow the log stream' do |_value, options|
    options[:follow] = true
  end

  action do |context|
    require 'hippo/cli'
    require 'hippo/util'

    cli = Hippo::CLI.setup(context)
    cli.preflight

    pod = context.options[:pod]
    if pod.nil?
      # Get all pod names that are running
      pods = cli.stage.get('pods')
      pods = pods.map(&:name)
      pod = Hippo::Util.select('Choose a pod to view logs', pods)
    end

    args = []
    args << '--all-containers'
    args << '-f' if context.options[:follow]

    command = cli.stage.kubectl('logs', pod, *args)
    exec *command
  end
end
