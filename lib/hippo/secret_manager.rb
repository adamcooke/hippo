# frozen_string_literal: true

require 'base64'
require 'hippo/secret'

module Hippo
  class SecretManager
    attr_reader :recipe
    attr_reader :stage
    attr_reader :key

    CIPHER = OpenSSL::Cipher.new('aes-256-gcm')

    def initialize(recipe, stage)
      @recipe = recipe
      @stage = stage
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
      object = {
        'apiVersion' => 'v1',
        'kind' => 'Secret',
        'type' => 'hippo.adam.ac/secret-encryption-key',
        'metadata' => { 'name' => 'hippo-secret-key', 'namespace' => @stage.namespace },
        'data' => { 'key' => Base64.encode64(secret_key64).gsub("\n", '').strip }
      }
      @recipe.kubernetes.apply_with_kubectl(@stage, object.to_yaml)
      @key = secret_key
    end

    # Download the current key from the Kubernetes API and set it as the
    # key for this instance
    #
    # @return [void]
    def download_key
      return if @key

      value = @recipe.kubernetes.get_with_kubectl(@stage, 'secret', 'hippo-secret-key').first
      return if value.nil?
      return if value.dig('data', 'key').nil?

      @key = Base64.decode64(Base64.decode64(value['data']['key']))
    rescue Hippo::Error => e
      raise unless e.message =~ /not found/
    end

    def key_available?
      download_key
      !@key.nil?
    end

    def secret(name)
      Secret.new(self, name)
    end

    def secrets
      Dir[File.join('secrets', @stage.name, '**', '*.{yml,yaml}')].map do |path|
        secret(path.split('/').last.sub(/\.ya?ml\z/, ''))
      end
    end

    def encrypt(value)
      CIPHER.encrypt
      iv = CIPHER.random_iv
      salt = SecureRandom.random_bytes(16)
      encrypted_value = Encryptor.encrypt(value: value.to_s, key: @key, iv: iv, salt: salt)
      'encrypted:' + Base64.encode64([
        Base64.encode64(encrypted_value),
        Base64.encode64(salt),
        Base64.encode64(iv)
      ].join('---')).gsub("\n", '')
    end

    # Decrypt the given value value and return it
    #
    # @param value [String]
    # @return [String]
    def decrypt(value)
      value = value.to_s
      if value =~ /\Aencrypted:(.*)/
        value = Base64.decode64(Regexp.last_match(1))
        encrypted_value, salt, iv = value.split('---', 3).map { |s| Base64.decode64(s) }
        Encryptor.decrypt(value: encrypted_value, key: @key, iv: iv, salt: salt).to_s
      else
        value
      end
    end
  end
end
