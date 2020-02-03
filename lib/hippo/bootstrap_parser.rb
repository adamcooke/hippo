# frozen_string_literal: true

require 'securerandom'
require 'secure_random_string'

module Hippo
  class BootstrapParser
    def self.parse(source)
      new(source).parse
    end

    TYPES = %w[placeholder password].freeze

    def initialize(source)
      @source = source || {}
    end

    def parse
      parse_hash(@source)
    end

    private

    def parse_hash(hash)
      hash.each_with_object({}) do |(key, value), hash|
        new_key = key.sub(/\A_/, '')
        hash[new_key] = if value.is_a?(Hash) && key[0] == '_'
                          parse_generator(value)
                        elsif value.is_a?(Hash)
                          parse_hash(value)
                        else
                          value.to_s
                        end
      end
    end

    def parse_generator(value)
      case value['type']
      when 'password'
        password = SecureRandomString.new(value['length'] || 24).to_s
        if value['addHashes']
          {
            'plain' => password,
            'sha1' => Digest::SHA1.hexdigest(password),
            'sha2' => Digest::SHA2.hexdigest(password),
            'sha256' => Digest::SHA256.hexdigest(password)
          }
        else
          password
        end
      when 'placeholder'
        value['prefix'].to_s + 'xxx' + value['suffix'].to_s
      when 'hex'
        SecureRandom.hex(value['size'] ? value['size'].to_i : 16)
      when 'random'
        Base64.encode64(SecureRandom.random_bytes(value['size'] ? value['size'].to_i : 16)).strip
      when nil
        raise Error, "A 'type' must be provided for each generated item"
      else
        raise Error, "Invalid generator type #{value['type']}"
      end
    end
  end
end
