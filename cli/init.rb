# frozen_string_literal: true

command :init do
  desc 'Initialize a new application to use Hippo'

  action do |context|
    require 'fileutils'

    path = context.args[0]

    if path.nil?
      raise Error, 'You must pass the name of the directory you wish to create your Hippo manifest'
    end

    root = File.expand_path(path)
    template_root = File.join(Hippo.root, 'template')

    raise Hippo::Error, "File already exists at #{root}" if File.exist?(root)

    FileUtils.mkdir_p(path)
    FileUtils.cp_r(File.join(template_root, '.'), root)

    puts "Initialized Hippo manifest in #{root}"
  end
end
