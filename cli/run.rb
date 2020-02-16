# frozen_string_literal: true

command :run do
  desc 'Create and run a pod using the given image'

  option '--command [COMMAND]', 'The command to run (defaults to /bin/bash)' do |value, options|
    options[:command] = value.to_s
  end

  action do |context|
    require 'hippo/cli'
    cli = Hippo::CLI.setup(context)
    cli.preflight

    image = cli.stage.images.values.first
    raise Error, "No image exists at #{image.image_url}" unless image.exists?

    command = context.options[:command] || '/bin/bash'

    pod_name = 'hp-run-' + SecureRandom.hex(4)
    kubectl_command = cli.stage.kubectl(
      'run', pod_name,
      '--restart', 'Never',
      '--rm',
      '--attach',
      '-it',
      '--image', image.image_url,
      '--command', '--', command
    )
    puts "Starting pod #{pod_name} with #{image.image_url}"
    exec *kubectl_command
  end
end
