# frozen_string_literal: true

require 'yaml'
require 'open3'
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

      def load_objects_from_path(path, decorator: nil)
        files = Dir[path]
        files.each_with_object({}) do |path, objects|
          file = load_yaml_from_file(path, decorator: decorator)
          objects[path] = file
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
        if ENV['EDITOR'].nil?
          raise Error, 'No EDITOR environment variable has been defined'
        end

        tmp_root = File.join(ENV['HOME'], '.hippo')
        FileUtils.mkdir_p(tmp_root)
        begin
          tmpfile = Tempfile.new([name, '.yaml'], tmp_root)
          tmpfile.write(contents)
          tmpfile.close
          Kernel.system("#{ENV['EDITOR']} #{tmpfile.path}")
          tmpfile.open
          tmpfile.read
        ensure
          tmpfile.unlink
        end
      end

      def confirm(question)
        response = ask(question)
        if %w[yes y].include?(response.downcase)
          puts
          true
        else
          false
        end
      end

      def select(question, items)
        items.each_with_index do |item, index|
          puts "#{index + 1}) #{item}"
        end
        selected_item = nil

        until selected_item
          response = ask(question)
          selected_item = items[response.to_i - 1]
          if selected_item.nil?
            puts "\e[31mThat is not a valid option. Try again.\e[0m"
          end
        end

        selected_item
      end

      def ask(question, default: nil)
        puts "\e[35m#{question}\e[0m" + (default ? " [#{default}]" : '')
        response = STDIN.gets
        response = response.to_s.strip
        response.empty? ? default : response
      end

      def system(command, stdin_data: nil)
        stdout, stderr, status = Open3.capture3(command, stdin_data: stdin_data)
        unless status.success?
          raise Error, "Command failed to execute: #{stderr}"
        end

        stdout
      end
    end
  end
end
