# frozen_string_literal: true

module Hippo
  class Secret
    HEADER = [
      '# This file is encrypted and managed by Hippo.',
      '# Use `hippo [stage] secrets:edit [name]` to make changes to it.',
      '#',
      '# Note: this cannot be applied directly to your Kubernetes server because',
      '# HippoEncryptedSecret is not a valid object. It will be automatically ',
      '# converted to a Secret when it is applied by Hippo.'
    ].join("\n")

    EDIT_HEADER = [
      '# This file has been unencrypted for you to edit it.',
      '# Make your changes and close your edit to re-encrypt and save the file.',
      '# You can change the apiVersion or add any additional metadata.',
      '#',
      '# You should not change the kind of document, it should be HippoEncryptedSecret.'
    ].join("\n")

    def initialize(manager, name)
      @manager = manager
      @name = name
    end

    # Return the path where this secret is stored
    #
    # @return [String]
    def path
      File.join(@manager.root, "#{@name}.yaml")
    end

    # Does this secret exist yet?
    #
    # @return [Boolean]
    def exists?
      File.file?(path)
    end

    # Create a new empty secret file on the file system
    #
    # @return [void]
    def create
      return if exists?

      od = ObjectDefinition.new(
        {
          'kind' => 'HippoEncryptedSecret',
          'apiVersion' => 'v1',
          'metadata' => {
            'name' => @name
          },
          'data' => {
            'example-value' => @manager.encrypt('This is an example encrypted value!')
          }
        },
        @manager.stage,
        clean: true
      )
      File.open(path, 'w') { |f| f.write(HEADER + "\n" + od.yaml) }
    end

    # Read the value from the file and decrypt all values that are present
    #
    # @return [String]
    def editable_yaml
      return unless exists?

      objects = Util.load_yaml_from_file(path)
      objects.each do |hash|
        hash['data'].each do |key, value|
          hash['data'][key] = @manager.decrypt(value)
        end
      end

      objects.map(&:to_yaml).join("\n---\n")
    end

    # Edit this secret
    #
    # @return [void]
    def edit
      contents = Util.open_in_editor("secret-#{@name}", EDIT_HEADER + "\n" + editable_yaml)
      yamls = Util.load_yaml_from_data(contents)
      ods = Util.create_object_definitions({ 'secret' => yamls }, @manager.stage, required_kinds: ['HippoEncryptedSecret'], clean: true)
      ods.each do |od|
        od['data'].each do |key, value|
          od['data'][key] = @manager.encrypt(value)
        end
      end
      File.open(path, 'w') { |f| f.write(HEADER + "\n" + ods.map(&:yaml).join("\n---\n")) }
    rescue StandardError => e
      puts "Failed to edit secret (#{e.message})"
      retry
    end

    # Return this secret as it can be exported to kubernetes
    #
    # @return [Array<ObjectDefinition>]
    def applyable_yaml
      objects = Util.load_yaml_from_file(path)
      objects = objects.each do |hash|
        hash['kind'] = 'Secret'
        hash['data'].each do |key, value|
          hash['data'][key] = Base64.encode64(@manager.decrypt(value)).gsub("\n", '')
        end
      end
      Util.create_object_definitions({ 'secret' => objects }, @manager.stage)
    end
  end
end
