# frozen_string_literal: true

command :readme do
  desc 'Display the README'

  action do |context|
    require 'hippo/cli'
    cli = Hippo::CLI.setup(context)
    cli.preflight

    readme = cli.stage.readme
    raise Error, 'No README is configured for this application' if readme.nil?

    puts '=' * 80
    puts readme
    puts '=' * 80
  end
end
