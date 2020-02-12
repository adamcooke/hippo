# frozen_string_literal: true

module Hippo
  module LiquidFilters
    def indent(text, depth = 2)
      text.split("\n").map.each_with_index do |p, i|
        i == 0 ? p : ' ' * depth + p
      end.join("\n")
    end

    def multiline(text)
      text.inspect
    end
  end
end
