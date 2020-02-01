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

    attr_reader :name

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

    # Return the unencrypted value for an item in this
    # secret file?
    #
    # @return [String]
    def unencrypted_value(key)
      hash = Util.load_yaml_from_file(path).first
      value = hash.dig('data', key.to_s)
      return nil if value.nil? || value.empty?

      @manager.decrypt(value)
    end

    def template_vars
      object = Util.load_yaml_from_file(path).first
      object['data'].each_with_object({}) do |(key, value), hash|
        hash[key] = @manager.decrypt(value)
      end
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
      FileUtils.mkdir_p(@manager.root)
      File.open(path, 'w') { |f| f.write(HEADER + "\n" + od.yaml) }
    end

    # Read the value from the file and decrypt all values that are present
    #
    # @return [String]
    def editable_yaml
      return unless exists?

      object = Util.load_yaml_from_file(path).first

      object['data'].each do |key, value|
        object['data'][key] = @manager.decrypt(value)
      end

      object.to_yaml
    end

    # Edit this secret
    #
    # @return [void]
    def edit
      contents = EDIT_HEADER + "\n" + editable_yaml
      begin
        contents = Util.open_in_editor("secret-#{@name}", contents)
        yaml = Util.load_yaml_from_data(contents).first
        ods = Util.create_object_definitions({ 'secret' => [yaml] }, @manager.stage, required_kinds: ['HippoEncryptedSecret'], clean: true)

        if ods.empty?
          raise Error, 'You need to specify a HippoEncryptedSecret object'
        end
        if ods.size > 1
          raise Error, 'You can only define one HippoEncryptedSecret per secret file'
        end

        od = ods.first

        if od.name != @name
          raise Error, 'You cannot change the name of the secret. It must match the file name'
        end

        od['data'].each do |key, value|
          od['data'][key] = @manager.encrypt(value)
        end

        FileUtils.mkdir_p(@manager.root)
        File.open(path, 'w') { |f| f.write(HEADER + "\n" + ods.map(&:yaml).join("\n---\n")) }
      rescue StandardError => e
        puts "Failed to edit secret (#{e.message})"
        puts 'Do you wish to edit again?'
        response = STDIN.gets
        retry if %w[y yes].include?(response.strip.downcase)
      end
    end

    # Return this secret as it can be exported to kubernetes
    #
    # @return [Array<ObjectDefinition>]
    def applyable_yaml
      object = Util.load_yaml_from_file(path).first
      object['kind'] = 'Secret'
      object['data'].each do |key, value|
        value = @manager.decrypt(value)
        value = @manager.stage.decorator.call(value)

        object['data'][key] = Base64.encode64(value).gsub("\n", '')
      end

      Util.create_object_definitions({ 'secret' => [object] }, @manager.stage)
    end
  end
end
