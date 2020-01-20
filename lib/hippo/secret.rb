# frozen_string_literal: true

require 'securerandom'
require 'openssl'
require 'encryptor'
require 'hippo/util'

module Hippo
  class Secret
    include Hippo::Util

    HEADER = [
      '# This file is encrypted and managed by Hippo.',
      '# Use `hippo secret [stage] [name]` to make changes to it.',
      '#',
      '# Note: this cannot be applied directly to your Kubernetes server because',
      '# HippoEncryptedSecret is not a valid object. It will be automatically ',
      '# converted to a Secret when it is applied by Hippo.'
    ].join("\n")

    def initialize(manager, name)
      @manager = manager
      @name = name
    end

    # Return the path to the stored encrypted secret file
    #
    # @return [String]
    def path
      File.join(@manager.recipe.root, 'secrets', @manager.stage.name, "#{@name}.yaml")
    end

    # Does the secret file currently exist on the file system?
    #
    # @return [Boolean]
    def exists?
      File.file?(path)
    end

    # Return the secret file as it should be applied to Kubernetes.
    #
    # @return [String]
    def to_secret_yaml
      decrypted_parts.map do |part, _array|
        part['kind'] = 'Secret'
        part['metadata'] ||= {}
        part['metadata']['namespace'] = @manager.stage.namespace

        part['data'].each do |key, value|
          part['data'][key] = Base64.encode64(value).gsub("\n", '').strip
        end
        part
      end.map { |p| p.hash.to_yaml } .join("---\n")
    end

    # Return the secret file as it should be displayed for editting
    #
    # @return [String]
    def to_editable_yaml
      decrypted_parts.map { |p| p.hash.to_yaml } .join("---\n")
    end

    # Edit a secret file by opening an editor and allow changes to be made.
    # When the editor completes, finish by writing the file back to the disk.
    #
    # @return [void]
    def edit
      return unless exists?

      # Obtain a list of parts and map them to the name of the secret
      # in the file.
      original_decrypted_part_data = parse_parts(load_yaml_from_path(path), :decrypt)
      original_encrypted_part_data = load_yaml_from_path(path).each_with_object({}) do |part, hash|
        next if part.nil? || part.empty?

        hash[part.dig('metadata', 'name')] = part['data']
      end
      original_part_data = original_decrypted_part_data.each_with_object({}) do |part, hash|
        name = part.dig('metadata', 'name')
        enc = original_encrypted_part_data[name]
        next if enc.nil?

        hash[part.dig('metadata', 'name')] = part['data'].each_with_object({}) do |(key, value), hash2|
          hash2[key] = [value, enc[key]]
        end
      end

      # Open the editor and gather what the user provides.
      saved_contents = open_in_editor("secret-#{@name}", to_editable_yaml)

      # This saved contents should now be validated to ensure it is valid
      # YAML and, if so, it should be encrypted and then saved into the
      # secret file as needed.
      begin
        yaml_parts = load_yaml_from_data(saved_contents)
        parts = parse_parts(yaml_parts, :encrypt, original_part_data)
        write(parts)
      rescue StandardError => e
        raise
        puts "An error occurred parsing your file: #{e.message}"
        saved_contents = open_in_editor("secret-#{@name}", saved_contents)
        retry
      end

      puts "#{@name} secret has been editted"
    end

    # Create a new templated encrypted secret with the given name
    #
    # @return [void]
    def create
      template = {
        'apiVersion' => 'v1',
        'kind' => 'HippoEncryptedSecret',
        'metadata' => {
          'name' => @name
        },
        'data' => {
          'example' => @manager.encrypt('This is an example secret!')
        }
      }
      write([template])
    end

    private

    def decrypted_parts
      return unless exists?

      yaml_parts = load_yaml_from_path(path)
      parse_parts(yaml_parts, :decrypt)
    end

    def parse_parts(yaml_parts, method, skips = {})
      yaml_parts.each_with_object([]) do |part, array|
        next if part.hash.nil? || part.hash.empty?

        part['data'].each do |key, value|
          skip = skips[part.dig('metadata', 'name')]
          part['data'][key] = if skip && skip[key] && skip[key][0] == value
                                skip[key][1]
                              else
                                @manager.public_send(method, value.to_s)
                              end
        end

        array << part
      end
    end

    # Write the array of given parts into a file along with a suitable
    # explanatory header.
    #
    # @return [void]
    def write(parts)
      parts = parts.map(&:to_yaml).join("---\n")
      data_to_write = HEADER + "\n" + parts

      FileUtils.mkdir_p(File.dirname(path))
      File.open(path, 'w') do |f|
        f.write(data_to_write)
      end
    end
  end
end
