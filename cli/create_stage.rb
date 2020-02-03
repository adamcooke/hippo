# frozen_string_literal: true

command :'create-stage' do
  desc 'Create a new stage'

  option '-h', '--hippofile [RECIPE]', 'The path to the Hippofile (defaults: ./Hippofile)' do |value, options|
    options[:hippofile] = value.to_s
  end

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
    manifest = Hippo::Manifest.load_from_file(context.options[:hippofile] || './Hippofile')

    stage_name = context.args[0]
    stage_path = File.join(manifest.root, 'stages', "#{stage_name}.yaml")

    if !context.options[:force] && File.file?(stage_path)
      puts "\e[31mA stage named '#{stage_name}' already exists.\e[0m"
      exit 1
    end

    namespace = context.options[:namespace] || "#{manifest.name}-#{stage_name}"
    context = context.options[:context] || nil

    yaml = {}
    yaml['name'] = stage_name
    yaml['namespace'] = namespace
    yaml['branch'] = manifest.bootstrap.dig('defaults', 'branch') || 'master'
    if tag = manifest.bootstrap.dig('defaults', 'image-tag')
      yaml['image-tag'] = tag
    end

    require 'hippo/bootstrap_parser'
    yaml['config'] = Hippo::BootstrapParser.parse(manifest.bootstrap['config'])

    require 'hippo/stage'
    stage = Hippo::Stage.new(manifest, yaml)

    require 'hippo/cli'
    cli = Hippo::CLI.new(manifest, stage)
    cli.apply_namespace

    if stage.secret_manager.key_available?
      puts 'Encryption key already exists for this namespace.'
    else
      puts "Creating new encryption key in #{stage.namespace} namespace"
      stage.secret_manager.create_key
    end

    FileUtils.mkdir_p(File.dirname(stage_path))
    File.open(stage_path, 'w') { |f| f.write(yaml.to_yaml.sub(/\A---\n/m, '')) }
    puts "Written new stage file to stages/#{stage.name}.yaml"

    secrets = Hippo::BootstrapParser.parse(manifest.bootstrap['secrets'])
    stage.secret_manager.write_file(secrets.to_yaml)
    puts "Written encrypted secrets into secrets/#{stage.name}.yaml"

    puts
    puts "\e[32mStage '#{stage.name}' has been created successfully.\e[0m"
    puts
    puts 'You can now add any appropriate configuration needed into the'
    puts 'stage file and into the encrypted secrets file if needed.'
    puts
  end
end
