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
      return nil if remote_refs.nil?

      remote_refs.dig('branches', branch, :sha)
    end

    def image_tag_for_stage(stage)
      if repository && stage.branch
        commit_ref_for_branch(stage.branch)
      elsif repository && stage.branch.nil?
        commit_ref_for_branch('master')
      elsif repository.nil? && stage.image_tag
        stage.image_tag
      else
        'latest'
      end
    end

    def image_path_for_stage(stage)
      "#{url}:#{image_tag_for_stage(stage)}"
    end

    def remote_refs
      return nil if repository.nil?

      @remote_refs ||= begin
        Git.ls_remote(repository)
      end
    end

    def can_check_for_existence?
      @options['existenceCheck'].nil? || @options['existenceCheck'] == true
    end

    def exists_for_stage?(stage)
      return true unless can_check_for_existence?

      credentials = Hippo.config.dig('docker', 'credentials', registry_host)

      tag = image_tag_for_stage(stage)

      http = Net::HTTP.new(registry_host, 443)
      http.use_ssl = true
      request = Net::HTTP::Head.new("/v2/#{registry_image_name}/manifests/#{tag}")
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
