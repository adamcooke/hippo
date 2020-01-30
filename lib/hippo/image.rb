# frozen_string_literal: true

require 'git'
require 'net/http'

module Hippo
  class Image
    def initialize(name, options)
      @name = name
      @options = options
    end

    attr_reader :name

    def url
      @options['url']
    end

    def repository
      @options['repository']
    end

    def template_vars
      {
        'url' => url,
        'repository' => repository
      }
    end

    def commit_ref_for_branch(branch)
      remote_refs.dig('branches', branch, :sha)
    end

    def image_path_for_branch(branch)
      "#{url}:#{commit_ref_for_branch(branch)}"
    end

    def remote_refs
      @remote_refs ||= begin
        Git.ls_remote(repository)
      end
    end

    def exists_for_commit?(commit)
      credentials = Hippo.config.dig('docker', 'credentials', registry_host)

      http = Net::HTTP.new(registry_host, 443)
      http.use_ssl = true
      request = Net::HTTP::Head.new("/v2/#{registry_image_name}/manifests/#{commit}")
      if credentials
        request.basic_auth(credentials['username'], credentials['password'])
      end
      response = http.request(request)
      case response
      when Net::HTTPOK
        true
      when Net::HTTPUnauthorized
        raise Error, "Could not authenticate to #{registry_host} to verify image existence"
      when Net::HTTPNotFound
        false
      else
        raise Error, "Got #{response.code} status when verifying imag existence with #{registry_host}"
      end
    end

    def registry_host
      url.split('/').first
    end

    def registry_image_name
      url.split('/', 2).last
    end
  end
end
