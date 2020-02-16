# frozen_string_literal: true

command :prepare do
  desc 'Prepare Kubernetes namespace (including installing all packages)'

  action do |context|
    require 'hippo/cli'
    cli = Hippo::CLI.setup(context)
    cli.preflight
    cli.apply_namespace
    cli.apply_config
    cli.install_all_packages
  end
end
