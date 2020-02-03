# frozen_string_literal: true

command :objects do
  desc 'Display all objects that will be exported'

  option '-h', '--hippofile [RECIPE]', 'The path to the Hippofile (defaults: ./Hippofile)' do |value, options|
    options[:hippofile] = value.to_s
  end

  option '-t', '--type [TYPE]', 'Limit which type of object to return (one of config, deployments or services)' do |value, options|
    options[:type] = value
  end

  option '--to-apply', 'Show objects as they would be applied to Kubernetes' do |_value, options|
    options[:to_apply] = true
  end

  action do |context|
    require 'hippo/cli'
    cli = Hippo::CLI.setup(context)

    method = if context.options[:to_apply]
               :yaml_to_apply
             else
               :yaml
             end

    groups = []
    if context.options[:type].nil? || context.options[:type] == 'config'
      groups << cli.stage.configs.map(&method)
    end

    if context.options[:type].nil? || context.options[:type] == 'deployments'
      groups << cli.stage.deployments.map(&method)
    end

    if context.options[:type].nil? || context.options[:type] == 'services'
      groups << cli.stage.services.map(&method)
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
