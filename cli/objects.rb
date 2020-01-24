# frozen_string_literal: true

command :objects do
  desc 'Build and publish an image for the given stage'

  option '-h', '--hippofile [RECIPE]', 'The path to the Hippofile (defaults: ./Hippofile)' do |value, options|
    options[:hippofile] = value.to_s
  end

  option '--types [TYPES]', 'The types of objects you wish to see' do |value, options|
    options[:types] = value.split(/,/)
  end

  action do |context|
    require 'hippo/cli_steps'
    steps = Hippo::CLISteps.setup(context)
    commit = steps.prepare_repository(fetch: false)

    if context.options[:types].nil? || context.options[:types].include?('all')
      types = Hippo::Kubernetes::OBJECT_DIRECTORY_NAMES
    else
      types = context.options[:types]
    end

    objects = []
    types.each do |type|
      next unless Hippo::Kubernetes::OBJECT_DIRECTORY_NAMES.include?(type)

      objects += steps.recipe.kubernetes.objects(type, steps.stage, commit, deploy_id: 'preview')
    end

    puts objects.map { |o| o.hash.to_yaml }
  end
end
