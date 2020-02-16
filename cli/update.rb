# frozen_string_literal: true

command :update do
  desc 'Get the latest updates from the remote manifest'
  action do
    require 'hippo/working_directory'
    wd = Hippo::WorkingDirectory.new

    unless wd.can_update?
      puts "No need to update #{wd.source_type} manifests"
      exit 0
    end

    if wd.last_updated_at
      puts "Last updated: #{wd.last_updated_at}"
    else
      puts 'Does not exist yet. Downloading for the first time.'
    end

    wd.update_from_remote(verbose: true)
  end
end
