# frozen_string_literal: true

require 'digest'
require 'git'
require 'hippo/error'

module Hippo
  class Repository
    def initialize(options)
      @options = options
    end

    def url
      @options['url']
    end

    # Return the path where this repository is stored on the local
    # computer.
    #
    # @return [String]
    def path
      return @options['path'] if @options['path']

      @path ||= begin
        digest = Digest::SHA256.hexdigest(url)
        File.join(ENV['HOME'], '.hippo', 'repos', digest)
      end
    end

    # Clone this repository into the working directory for this
    # application.
    #
    # @return [Boolean]
    def clone
      if File.directory?(path)
        raise RepositoryAlreadyClonedError, "Repository has already been cloned to #{path}. Maybe you just want to pull?"
      end

      @git = Git.clone(url, path)
      true
    rescue Git::GitExecuteError => e
      raise RepositoryCloneError, e.message
    end

    # Has this been cloned?
    #
    # @return [Boolean]
    def cloned?
      File.directory?(path)
    end

    # Fetch the latest copy of this repository
    #
    # @return [Boolean]
    def fetch
      git.fetch
      true
    rescue Git::GitExecuteError => e
      raise RepositoryFetchError, e.message
    end

    # Checkout the version of the application for the given commit or
    # branch name in the local copy.
    #
    # @param ref [String]
    # @return [Boolean]
    def checkout(ref)
      git.checkout("origin/#{ref}")
      true
    rescue Git::GitExecuteError => e
      if e.message =~ /did not match any file\(s\) known to git/
        raise RepositoryCheckoutError, "No branch named '#{ref}' found in repository"
      else
        raise RepositoryCheckoutError, e.message
      end
    end

    # Return the commit reference for the currently checked out branch
    #
    # @return [String]
    def commit
      git.log(1).first
    end

    # Get the commit reference for the given branch on the remote
    # repository by asking it directly.
    #
    # @param name [String]
    # @return [Git::Commit]
    def commit_for_branch(branch)
      git.object("origin/#{branch}").log(1).first
    rescue Git::GitExecuteError => e
      if e.message =~ /Not a valid object name/
        raise Error, "'#{branch}' is not a valid branch name in repository"
      else
        raise
      end
    end

    # Return the template variables for a repository
    #
    # @return [Hash]
    def template_vars
      {
        'url' => url,
        'path' => path
      }
    end

    private

    def git
      @git ||= begin
        if cloned?
          Git.open(path)
        else
          raise Error, 'Could not create a git instance because there is no repository cloned for it.'
        end
      end
    end
  end
end
