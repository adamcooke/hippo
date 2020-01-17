# frozen_string_literal: true

require 'hippo/repository'

describe Hippo::Repository do
  before(:all) do
    @repo_url = '/tmp/hippo-test-repo-source'
    FileUtils.rm_rf(@repo_url)
    Git.clone('https://github.com/adamcooke/hippo-test-repo', @repo_url)
  end

  after(:all) do
    FileUtils.rm_rf(@repo_url) if @repo_url
  end

  context '#clone' do
    it 'should clone the repository' do
      FileUtils.rm_rf('/tmp/hippo-tests/repo')
      repository = Hippo::Repository.new(
        'url' => @repo_url,
        'path' => '/tmp/hippo-tests/repo'
      )
      expect(repository.clone).to be true
      expect(File.directory?(repository.path)).to be true
      expect(File.directory?(File.join(repository.path, '.git'))).to be true
      expect(File.file?(File.join(repository.path, 'Hello'))).to be true
    end

    it 'should raise an error if the repository already exists' do
      FileUtils.mkdir_p('/tmp/hippo-tests/repo')
      repository = Hippo::Repository.new(
        'url' => @repo_url,
        'path' => '/tmp/hippo-tests/repo'
      )
      expect { repository.clone }.to raise_error Hippo::RepositoryAlreadyClonedError
    end

    it 'should raise an error if the repo does not exist on the remote' do
      FileUtils.rm_rf('/tmp/hippo-tests/repo')
      repository = Hippo::Repository.new(
        'url' => 'git://github.com/adamcooke/invalid-never-to-exist',
        'path' => '/tmp/hippo-tests/repo'
      )
      expect { repository.clone }.to raise_error Hippo::RepositoryCloneError
    end
  end

  context '#fetch' do
    it 'should fetch the latest repo' do
      FileUtils.rm_rf('/tmp/hippo-tests/repo')
      repository = Hippo::Repository.new(
        'url' => @repo_url,
        'path' => '/tmp/hippo-tests/repo'
      )
      repository.clone
      expect(repository.fetch).to be true
    end
  end

  context '#checkout' do
    before(:all) do
      FileUtils.rm_rf('/tmp/hippo-tests/repo')
      @repository = Hippo::Repository.new(
        'url' => 'git://github.com/adamcooke/hippo-test-repo',
        'path' => '/tmp/hippo-tests/repo'
      )
      @repository.clone
    end

    it 'should be able to checkout a branch' do
      expect(File.file?('/tmp/hippo-tests/repo/Staging')).to be false
      expect(@repository.checkout('staging')).to be true
      expect(File.file?('/tmp/hippo-tests/repo/Staging')).to be true
    end

    it 'should raise an error if the branch does not exist' do
      expect { @repository.checkout('missing') }.to raise_error(Hippo::RepositoryCheckoutError)
    end
  end
end
