# frozen_string_literal: true

command :vars do
  desc 'Show all variables available for use in this stage'

  option '-h', '--hippofile [RECIPE]', 'The path to the Hippofile (defaults: ./Hippofile)' do |value, options|
    options[:hippofile] = value.to_s
  end

  action do |context|
    require 'hippo/cli'
    cli = Hippo::CLI.setup(context)

    hash = {
      'stage' => cli.stage.template_vars,
      'manifest' => cli.manifest.template_vars
    }.to_yaml.gsub(/^(\s*[\w\-]+)\:(.*)/) do
      "\e[32m#{Regexp.last_match(1)}:\e[0m" + Regexp.last_match(2)
    end
    puts hash
  end
end
