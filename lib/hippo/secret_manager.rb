# frozen_string_literal: true

require 'encryptor'
require 'openssl'
require 'base64'

module Hippo
  class SecretManager
    attr_reader :stage

    def initialize(stage)
      @stage = stage
    end

    CIPHER = OpenSSL::Cipher.new('aes-256-gcm')

    def path
      File.join(@stage.config_root, 'secrets.yaml')
    end

    # Download the current key from the Kubernetes API and set it as the
    # key for this instance
    #
    # @return [void]
    def download_key
      return if @key

      Util.action 'Downloading secret encryption key...' do |state|
        begin
          value = @stage.get('secret', 'hippo-secret-key').first

          if value.nil? || value.dig('data', 'key').nil?
            state.call('not found')
            return
          end

          @key = Base64.decode64(Base64.decode64(value['data']['key']))
        rescue Hippo::Error => e
          if e.message =~ /not found/
            state.call('not found')
          else
            raise
          end
        end
      end
    end

    # Is there a key availale in this manager?
    #
    # @return [Boolean]
    def key_available?
      download_key
      !@key.nil?
    end

    # Generate and publish a new secret key to the Kubernetes API.
    #
    # @return [void]
    def create_key
      if key_available?
        raise Hippo::Error, 'A key already exists on Kubernetes. Remove this first.'
      end

      CIPHER.encrypt
      secret_key = CIPHER.random_key
      secret_key64 = Base64.encode64(secret_key).gsub("\n", '').strip
      od = ObjectDefinition.new({
                                  'apiVersion' => 'v1',
                                  'kind' => 'Secret',
                                  'type' => 'hippo.adam.ac/secret-encryption-key',
                                  'metadata' => { 'name' => 'hippo-secret-key' },
                                  'data' => { 'key' => secret_key64 }
                                }, @stage)
      @stage.apply([od])
      @key = secret_key
    end

    # Encrypt a given value?
    def encrypt(value)
      unless key_available?
        raise Error, 'Cannot encrypt values because there is no key'
      end

      CIPHER.encrypt
      iv = CIPHER.random_iv
      salt = SecureRandom.random_bytes(16)
      encrypted_value = Encryptor.encrypt(value: value.to_s, key: @key, iv: iv, salt: salt)
      Base64.encode64([
        Base64.encode64(encrypted_value),
        Base64.encode64(salt),
        Base64.encode64(iv)
      ].join('---'))
    end

    # Decrypt the given value value and return it
    #
    # @param value [String]
    # @return [String]
    def decrypt(value)
      value = Base64.decode64(value.to_s)
      encrypted_value, salt, iv = value.split('---', 3).map { |s| Base64.decode64(s) }
      Encryptor.decrypt(value: encrypted_value, key: @key, iv: iv, salt: salt).to_s
    end

    # Does a secrets file exist for this application.
    #
    # @return [Boolean]
    def exists?
      File.file?(path)
    end

    # Create an empty encrypted example secret file
    #
    # @return [void]
    def create
      unless key_available?
        raise Error, 'Cannot create secret file because no key is available for encryption'
      end

      return if exists?

      yaml = { 'example' => 'This is an example secret2!' }.to_yaml
      FileUtils.mkdir_p(File.dirname(path))
      File.open(path, 'w') { |f| f.write(encrypt(yaml)) }
    end

    def edit
      create unless exists?

      unless key_available?
        raise Error, 'Cannot create edit file because no key is available for decryption'
      end

      old_contents = decrypt(File.read(path))
      new_contents = Util.open_in_editor('secret', old_contents)
      if old_contents != new_contents
        write_file(new_contents)
      else
        puts 'No changes detected. Not re-encrypting secret file.'
      end
    end

    def write_file(contents)
      FileUtils.mkdir_p(File.dirname(path))
      File.open(path, 'w') { |f| f.write(encrypt(contents)) }
    end

    def all
      @all ||= begin
        return {} unless exists?

        unless key_available?
          raise Error, 'No encryption key is available to decrypt secrets'
        end

        YAML.safe_load(decrypt(File.read(path)))
      end
    rescue Psych::SyntaxError => e
      raise Error, "Could not parse secrets file: #{e.message}"
    end
  end
end
