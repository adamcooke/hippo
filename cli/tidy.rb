# frozen_string_literal: true

command :tidy do
  desc 'Remove live objects that are not referenced by the manifest'
  action do |context|
    require 'hippo/cli'
    cli = Hippo::CLI.setup(context)
    cli.preflight

    objects_to_prune = cli.stage.live_objects(pruneable_only: true)
    if objects_to_prune.empty?
      puts 'There are no objects to tidy'
      exit 0
    end

    puts "Found #{objects_to_prune.size} object(s) to tidy"
    puts
    objects_to_prune.each do |obj|
      $stdout.print '  ' + obj[:live].kind.ljust(25)
      $stdout.print obj[:live].name
      puts
    end
    puts

    require 'hippo/util'
    unless Hippo::Util.confirm('Do you wish to continue?')
      puts 'No problem, not removing anything right now'
      exit 0
    end

    cli.stage.delete_pruneable_objects
  end
end
