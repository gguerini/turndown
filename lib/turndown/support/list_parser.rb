# frozen_string_literal: true

module Turndown
  module Support
    # Parses a comma-separated string into an array of trimmed values.
    # Commas escaped with a backslash (\,) are preserved in the value.
    module ListParser
      def self.call(value)
        return [] if value.nil?

        value.to_s.split(/(?<!\\),\s?/).map { |v| v.strip.gsub('\,', ',') }
      end
    end
  end
end
