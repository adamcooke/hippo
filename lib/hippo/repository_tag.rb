# frozen_string_literal: true

module Hippo
  class RepositoryTag
    def initialize(options)
      @options = options
    end

    def branch
      @options['branch'] || 'master'
    end

    def tag
      @tag ||= commit_ref_for_branch(branch)
    end

    def to_s
      tag
    end

    private

    def commit_ref_for_branch(branch)
      return nil if remote_refs.nil?

      remote_refs.dig('branches', branch, :sha)
    end

    def remote_refs
      return nil if @options['url'].nil?

      @remote_refs ||= begin
        puts "Getting remote refs from #{@options['url']}"
        Git.ls_remote(@options['url'])
      end
    end
  end
end
