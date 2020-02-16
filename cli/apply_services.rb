# frozen_string_literal: true

command :'apply-services' do
  desc 'Apply service configuration'

  action do |context|
    require 'hippo/cli'
    cli = Hippo::CLI.setup(context)
    cli.preflight
    cli.apply_services
  end
end
