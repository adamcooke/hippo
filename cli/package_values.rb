# frozen_string_literal: true

command :'package:values' do
  desc 'Display the values file that will be used for all packages'

  option '-h', '--hippofile [RECIPE]', 'The path to the Hippofile (defaults: ./Hippofile)' do |value, options|
    options[:hippofile] = value.to_s
  end

  action do |context|
    require 'hippo/cli'
    cli = Hippo::CLI.setup(context)
    cli.preflight

    cli.stage.packages.values.each do |package|
      puts "\e[33m#{'=' * 80}"
      puts package.name
      puts "#{'=' * 80}\e[0m"
      puts package.final_values.to_yaml(line_width: -1).sub(/\A---\n/, '')
    end
  end
end
