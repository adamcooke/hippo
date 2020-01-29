# frozen_string_literal: true

require File.expand_path('lib/hippo/version', __dir__)
Gem::Specification.new do |s|
  s.name          = 'hippo-cli'
  s.description   = 'A utility tool for deploying and building with Docker & Kubernetes'
  s.summary       = s.description
  s.homepage      = 'https://github.com/adamcooke/hippo'
  s.version       = Hippo::VERSION
  s.files         = Dir.glob('{bin,cli,lib,template}/**/*')
  s.require_paths = ['lib']
  s.authors       = ['Adam Cooke']
  s.email         = ['me@adamcooke.io']
  s.licenses      = ['MIT']
  s.cert_chain    = ['certs/adamcooke.pem']
  s.bindir = 'bin'
  s.executables << 'hippo'
  if $PROGRAM_NAME =~ /gem\z/
    s.signing_key = File.expand_path('~/.gem/signing-key.pem')
  end
  s.add_dependency 'encryptor', '>= 3.0', '< 4.0'
  s.add_dependency 'git', '>= 1.5.0', '< 2.0'
  s.add_dependency 'liquid', '>= 4.0.3', '< 5.0'
  s.add_dependency 'swamp-cli', '>= 1.0', '< 2.0'
end
