# frozen_string_literal: true

command :logs do
  desc 'Display logs for a particular pod'

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
      stdout, stderr, status = Open3.capture3(*cli.stage.kubectl('get', 'pods'))
      pod_names = []
      stdout.split("\n").each_with_index do |line, index|
        if index.zero?
          puts "      #{line}"
        else
          puts "\e[33m#{index.to_s.rjust(3)})\e[0m  #{line}"
          pod_names << line.split(/\s+/, 2).first
        end
      end

      raise Error, 'There are no pods running' if pod_names.empty?

      until pod
        pod_id = Hippo::Util.ask('Choose a pod to view logs').to_i
        next if pod_id.zero? || pod_id.negative?

        pod = pod_names[pod_id.to_i - 1]
      end
    end

    args = []
    args << '--all-containers'
    args << '-f' if context.options[:follow]

    command = cli.stage.kubectl('logs', pod, *args)
    exec *command
  end
end
