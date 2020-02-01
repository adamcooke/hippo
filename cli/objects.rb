# frozen_string_literal: true

command :objects do
  desc 'Display all objects that will be exported'

  option '-h', '--hippofile [RECIPE]', 'The path to the Hippofile (defaults: ./Hippofile)' do |value, options|
    options[:hippofile] = value.to_s
  end

  option '-t', '--type [TYPE]', 'Limit which type of object to return (one of config, deployments or services)' do |value, options|
    options[:type] = value
  end

  action do |context|
    require 'hippo/cli'
    cli = Hippo::CLI.setup(context)

    groups = []
    if context.options[:type].nil? || context.options[:type] == 'config'
      groups << cli.stage.configs.map(&:yaml)

      if cli.stage.secret_manager.key_available?
        groups << cli.stage.secret_manager.secrets.map(&:applyable_yaml).flatten.map do |object|
          object['data'].each do |key, value|
            object['data'][key] = Base64.decode64(value)
          end
          object.yaml
        end

      end
    end

    if context.options[:type].nil? || context.options[:type] == 'deployments'
      groups << cli.stage.deployments.map(&:yaml)
    end

    if context.options[:type].nil? || context.options[:type] == 'services'
      groups << cli.stage.services.map(&:yaml)
    end

    groups.each do |group|
      group.each do |object|
        puts object
          .gsub(/^kind\: (.*)$/) { "kind: \e[36m#{Regexp.last_match(1)}\e[0m" }
          .gsub(/^---$/) { "\e[33m#{'=' * 80}\e[0m" }
      end
    end
  end
end
