# frozen_string_literal: true

require 'yaml'

module Hippo
  class ObjectDefinition
    def initialize(object, stage, clean: false)
      @object = object
      @stage = stage
    end

    def [](name)
      @object[name]
    end

    def dig(*args)
      @object.dig(*args)
    end

    def name
      metadata['name']
    end

    def metadata
      @object['metadata'] ||= {}
    end

    def kind
      @object['kind']
    end

    def yaml
      @object.to_yaml(line_width: -1)
    end

    def yaml_to_apply
      object = ObjectDefinition.new(@object.dup, @stage)
      object.insert_namespace!
      object.insert_default_labels!
      object.base64_encode_data! if kind == 'Secret'
      object.yaml
    end

    def base64_encode_data!(object = @object['data'])
      object.each do |key, value|
        object[key] = if value.is_a?(Hash)
                        base64_encode_data!(value)
                      else
                        Base64.encode64(value.to_s).gsub(/\n/, '').strip
                      end
      end
    end

    def insert_namespace!
      metadata['namespace'] = @stage.namespace
    end

    def insert_default_labels!
      metadata['labels'] ||= {}
      metadata['labels']['app.kubernetes.io/name'] = @stage.manifest.name
      metadata['labels']['app.kubernetes.io/instance'] = @stage.name
      metadata['labels']['app.kubernetes.io/managed-by'] = 'hippo'
    end

    def insert_deployment_id!(deployment_id)
      metadata['labels'] ||= {}
      metadata['labels']['hippo.adam.ac/deployID'] = deployment_id

      # For deployments, insert the ID on the template too for deployments.
      if kind == 'Deployment' && pod_metadata = @object.dig('spec', 'template', 'metadata')
        pod_metadata['labels'] ||= {}
        pod_metadata['labels']['hippo.adam.ac/deployID'] = deployment_id
      end
    end
  end
end
