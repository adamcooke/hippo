# frozen_string_literal: true

command :setup do
  desc 'Create a new configuration directory'

  option '--local [PATH]', 'Use a local manifest from the given path' do |value, options|
    options[:local] = value
  end

  option '--remote [REPO]', 'Use a repo manifest from the given repository' do |value, options|
    options[:remote] = value
  end

  option '-p [PATH]', '--path [PATH]', 'Path within the remote repository' do |value, options|
    options[:path] = value
  end

  option '-b [BRANCH]', '--branch [BRANCH]', 'Branch on remote repository' do |value, options|
    options[:branch] = value
  end

  action do |context|
    path = context.args[0]
    raise Error, 'Provide path as first argument' if path.nil?

    path = File.expand_path(path)

    raise Error, "Directory already exists at #{path}" if File.exist?(path)

    if context.options[:local] && context.options[:remote]
      raise Error, 'Only specify --local OR --remote'
    end

    require 'fileutils'
    FileUtils.mkdir_p(path)
    source = {}
    if local_path = context.options[:local]
      source['type'] = 'local'
      source['localOptions'] = {
        'path' => File.expand_path(local_path)
      }
    elsif repo = context.options[:remote]
      source['type'] = 'remote'
      source['remoteOptions'] = { 'repository' => repo }
      if context.options[:path]
        source['remoteOptions']['path'] = context.options[:path]
      end
      if context.options[:branch]
        source['remoteOptions']['branch'] = context.options[:branch]
      end
    end

    require 'yaml'
    config = { 'source' => source }
    File.open(File.join(path, 'manifest.yaml'), 'w') { |f| f.write(config.to_yaml) }
    puts "Created configuration directory at #{path}"

    require 'hippo/working_directory'
    wd = Hippo::WorkingDirectory.new(path)
    if wd.can_update?
      puts 'Updating local copy of remote repository...'
      wd.update_from_remote
      puts "\e[32mUpdate completed successfully.\e[0m"
      puts
      puts "  Repository....: \e[33m#{wd.remote_repository}\e[0m"
      puts "  Branch........: \e[33m#{wd.remote_branch}\e[0m"
      puts "  Path..........: \e[33m#{wd.remote_path}\e[0m"
      puts
    end
  end
end
