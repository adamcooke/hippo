# frozen_string_literal: true

command :stages do
  desc 'List all stages that are available'

  action do |_context|
    require 'hippo/manifest'
    wd = Hippo::WorkingDirectory.new

    if wd.stages.empty?
      puts 'There are no stages configured yet.'
      puts 'Use the following command to create one:'
      puts
      puts '  hippo [name] create'
      puts
      exit 0
    end

    wd.stages.each do |_, stage|
      puts "- #{stage.name}"
    end
  end
end
