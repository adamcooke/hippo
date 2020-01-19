# frozen_string_literal: true

require 'hippo/error'
require 'hippo/yaml_part'

module Hippo
  module Util
    def load_yaml_from_path(path)
      return nil if path.nil?
      return nil unless File.file?(path)

      data = File.read(path)
      load_yaml_from_data(data, path)
    end

    def load_yaml_from_data(data, path = nil)
      parts = data.split(/^\-\-\-$/)
      parts.each_with_index.map do |part, index|
        YAMLPart.new(part, path, index)
      end
    end

    def load_yaml_from_directory(path)
      return [] if path.nil?
      return [] unless File.directory?(path)

      Dir[File.join(path, '**', '*.{yaml,yml}')].sort.each_with_object([]) do |path, array|
        yaml = load_yaml_from_path(path)
        next if yaml.nil?

        array << yaml
      end.flatten
    end

    def open_in_editor(name, contents)
      tmp_root = File.join(ENV['HOME'], '.hippo')
      FileUtils.mkdir_p(tmp_root)
      begin
        tmpfile = Tempfile.new([name, '.yaml'], tmp_root)
        tmpfile.write(contents)
        tmpfile.close
        system("#{ENV['EDITOR']} #{tmpfile.path}")
        tmpfile.open
        tmpfile.read
      ensure
        tmpfile.unlink
      end
    end
  end
end
