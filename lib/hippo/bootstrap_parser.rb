# frozen_string_literal: true

require 'securerandom'
require 'secure_random_string'
require 'openssl'

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
      when 'rsa'
        OpenSSL::PKey::RSA.new(value['size'] ? value['size'].to_i : 2048).to_s
      when 'certificate'
        key = OpenSSL::PKey::RSA.new(value['key_size'] ? value['key_size'].to_i : 2048)

        cert = OpenSSL::X509::Certificate.new
        cert.subject = cert.issuer = OpenSSL::X509::Name.new(
          [
            ['C', value['country'] || 'GB'],
            ['O', value['organization'] || 'Default'],
            ['OU', value['organization_unit'] || 'Default'],
            ['CN', value['common_name'] || 'default']
          ]
        )
        cert.not_before = Time.now
        cert.not_after = Time.now + (60 * 60 * 24 * (value['days'] ? value['days'].to_i : 730))
        cert.public_key = key.public_key
        cert.serial = 0x0
        cert.version = 2
        cert.sign key, OpenSSL::Digest::SHA256.new
        { 'certificate' => cert.to_s, 'key' => key.to_s }
      when nil
        raise Error, "A 'type' must be provided for each generated item"
      else
        raise Error, "Invalid generator type #{value['type']}"
      end
    end
  end
end
