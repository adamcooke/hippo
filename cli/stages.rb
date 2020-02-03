# frozen_string_literal: true

command :stages do
  desc 'List all stages that are available'
  option '-h', '--hippofile [RECIPE]', 'The path to the Hippofile (defaults: ./Hippofile)' do |value, options|
    options[:hippofile] = value.to_s
  end

  action do |context|
    require 'hippo/manifest'
    manifest = Hippo::Manifest.load_from_file(context.options[:hippofile] || './Hippofile')

    if manifest.stages.empty?
      puts 'There are no stages configured yet.'
      puts 'Use the following command to create one:'
      puts
      puts '  hippo [name] create'
      puts
      exit 0
    end

    manifest.stages.each do |_, stage|
      puts " * #{stage.name}"
    end
  end
end
