# frozen_string_literal: true

module Hippo
  class Stage
    def initialize(options)
      @options = options
    end

    def name
      @options['name']
    end

    def branch
      @options['branch']
    end

    def namespace
      @options['namespace']
    end

    def context
      @options['context']
    end

    def template_vars
      {
        'name' => name,
        'branch' => branch,
        'namespace' => namespace,
        'vars' => @options['vars'] || {}
      }
    end

    def kubectl(*command)
      (kubectl_base_command + command).join(' ')
    end

    def kubectl_base_command
      command = ['kubectl']
      command += ['--context', context] if context
      command += ['-n', namespace]
      command
    end
  end
end
