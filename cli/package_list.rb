# frozen_string_literal: true

command :'package:list' do
  desc 'List all available packages with status'

  option '-h', '--hippofile [RECIPE]', 'The path to the Hippofile (defaults: ./Hippofile)' do |value, options|
    options[:hippofile] = value.to_s
  end

  action do |context|
    require 'hippo/cli'
    cli = Hippo::CLI.setup(context)
    cli.preflight

    if cli.stage.packages.empty?
      puts 'There are no configured packages'
      exit 0
    end

    puts 'Getting package details...'

    packages = []
    cli.stage.packages.values.sort_by(&:name).each do |package|
      packages << { name: package.name, installed: package.installed?, package: package.package }
    end

    packages.each do |package|
      STDOUT.print package[:name].ljust(20)
      STDOUT.print package[:package].ljust(30)
      STDOUT.print '[ '
      if package[:installed]
        STDOUT.print "\e[32m Installed \e[0m"
      else
        STDOUT.print "\e[31mNot present\e[0m"
      end
      STDOUT.print ' ]'
      puts
    end
  end
end
