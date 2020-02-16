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

    puts "Updating from #{wd.remote_repository}..."
    wd.update_from_remote

    puts "\e[32mUpdate completed successfully.\e[0m"
    puts
    puts "  Repository....: \e[33m#{wd.remote_repository}\e[0m"
    puts "  Branch........: \e[33m#{wd.remote_branch}\e[0m"
    puts "  Path..........: \e[33m#{wd.remote_path}\e[0m"
    puts
  end
end
