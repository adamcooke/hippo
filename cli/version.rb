# frozen_string_literal: true

command :version do
  desc 'Show all variables available for use in this stage'
  action do
    puts 'Hippo v' + Hippo::VERSION
  end
end
