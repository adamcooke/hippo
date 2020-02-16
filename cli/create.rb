# frozen_string_literal: true

command :create do
  desc 'Create a new stage'

  option '-n', '--namespace [NAMESPACE]', 'The namespace for the new stage' do |value, options|
    options[:namespace] = value
  end

  option '-c', '--context [CONTEXT]', 'The context for the new stage' do |value, options|
    options[:context] = value
  end

  option '--force', 'Override existing stage configuration' do |_value, options|
    options[:force] = true
  end

  action do |context|
    require 'hippo/manifest'
    wd = Hippo::WorkingDirectory.new

    stage_name = CURRENT_STAGE
    stage_path = File.join(wd.root, stage_name, 'config.yaml')

    if !context.options[:force] && File.file?(stage_path)
      puts "\e[31mA stage named '#{stage_name}' already exists. Use --force to overwrite configuration.\e[0m"
      exit 1
    end

    require 'hippo/util'

    namespace = context.options[:namespace]
    if namespace.nil?
      namespace = Hippo::Util.ask('Enter a namespace for this stage', default: "#{wd.manifest.name}-#{stage_name}")
    end

    context_name = context.options[:context]
    if context_name.nil?
      context_name = Hippo::Util.ask('Enter a kubectl context for this stage', default: Hippo.current_kubectl_context)
    end

    yaml = {}
    yaml['name'] = stage_name
    yaml['namespace'] = namespace
    yaml['context'] = context_name

    require 'hippo/bootstrap_parser'
    yaml['config'] = Hippo::BootstrapParser.parse(wd.manifest.bootstrap['config'])

    require 'hippo/stage'
    stage = Hippo::Stage.new(wd.manifest, File.dirname(stage_path), yaml)

    require 'hippo/cli'
    cli = Hippo::CLI.new(wd.manifest, stage)
    cli.apply_namespace

    if stage.secret_manager.key_available?
      puts 'Encryption key already exists for this namespace.'
    else
      puts "Creating new encryption key in #{stage.namespace} namespace"
      stage.secret_manager.create_key
    end

    FileUtils.mkdir_p(File.dirname(stage_path))
    File.open(stage_path, 'w') { |f| f.write(yaml.to_yaml.sub(/\A---\n/m, '')) }
    puts "Written new stage file to #{stage.name}/config.yaml"

    secrets = Hippo::BootstrapParser.parse(wd.manifest.bootstrap['secrets'])
    stage.secret_manager.write_file(secrets.to_yaml)
    puts "Written encrypted secrets into #{stage.name}/secrets.yaml"

    puts
    puts "\e[32mStage '#{stage.name}' has been created successfully.\e[0m"
    puts
    puts 'You can now add any appropriate configuration needed into the'
    puts 'stage file and into the encrypted secrets file if needed.'
    puts
  end
end
