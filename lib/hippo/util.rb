# frozen_string_literal: true

require 'yaml'
require 'hippo/error'
require 'hippo/object_definition'

module Hippo
  module Util
    class << self
      def load_yaml_from_file(path, decorator: nil)
        raise Error, "No file found at #{path} to load" unless File.file?(path)

        file = File.read(path)
        load_yaml_from_data(file, path: path, decorator: decorator)
      end

      def load_yaml_from_data(data, path: nil, decorator: nil)
        data = decorator.call(data) if decorator

        parts = data.split(/^\-\-\-\s*$/)
        parts.each_with_index.each_with_object([]) do |(p, i), array|
          begin
            yaml = YAML.safe_load(p)
            next unless yaml.is_a?(Hash)

            array << yaml
          rescue Psych::SyntaxError => e
            raise Error, e.message.sub('(<unknown>): ', "(#{path}[#{i}]): ")
          end
        end
      end

      def create_object_definitions(hash, stage, required_kinds: nil, clean: false)
        index = 0
        hash.each_with_object([]) do |(path, objects), array|
          objects.each_with_index do |object, inner_index|
            od = ObjectDefinition.new(object, stage, clean: clean)

            if od.name.nil?
              raise Error, "All object defintions must have a name. Missing metadata.name for object in #{path} at index #{inner_index}"
            end

            if od.kind.nil?
              raise Error, "All object definitions must have a kind defined. Check #{path} at index #{inner_index}"
            end

            if required_kinds && !required_kinds.include?(od.kind)
              raise Error, "Kind '#{od.kind}' cannot be defined in #{path} at index #{inner_index}. Only kinds #{required_kinds} are permitted."
            end

            array << od
            index += 1
          end
        end
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
end
