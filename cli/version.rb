# frozen_string_literal: true

command :version do
  desc 'Print current Hippo version'
  action do
    puts 'Hippo v' + Hippo::VERSION
  end
end
