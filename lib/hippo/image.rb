# frozen_string_literal: true

require 'git'
require 'net/http'
require 'hippo/repository_tag'

module Hippo
  class Image
    def initialize(name, options)
      @name = name
      @options = options
    end

    attr_reader :name

    def host
      @options['host']
    end

    def image_name
      @options['name']
    end

    def tag
      @tag ||= begin
        if @options['tag'].is_a?(Hash) && repo = @options['tag']['fromRepository']
          RepositoryTag.new(repo)
        elsif @options['tag'].nil?
          'latest'
        else
          @options['tag'].to_s
        end
      end
    end

    def image_url
      if host
        "#{host}/#{image_name}:#{tag}"
      else
        "#{image_name}:#{tag}"
      end
    end

    def template_vars
      @template_vars ||= {
        'host' => host,
        'name' => image_name,
        'tag' => tag.to_s,
        'url' => image_url
      }
    end

    def can_check_for_existence?
      @options['existenceCheck'].nil? ||
        @options['existenceCheck'] == true
    end

    def exists?
      return true if host.nil?
      return true unless can_check_for_existence?

      credentials = Hippo.config.dig('docker', 'credentials', host)
      http = Net::HTTP.new(host, 443)
      http.use_ssl = true
      request = Net::HTTP::Head.new("/v2/#{image_name}/manifests/#{tag}")
      if credentials
        request.basic_auth(credentials['username'], credentials['password'])
      end
      response = http.request(request)

      case response
      when Net::HTTPOK
        true
      when Net::HTTPUnauthorized
        raise Error, "Could not authenticate to #{host} to verify image existence"
      when Net::HTTPNotFound
        false
      else
        raise Error, "Got #{response.code} status when verifying imag existence with #{host}"
      end
    end
  end
end
