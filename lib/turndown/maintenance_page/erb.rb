require 'erb'
require 'tilt'
require 'tilt/erb'
require_relative './html'

module Turndown
  module MaintenancePage
    class Erb < Turndown::MaintenancePage::HTML

      def content
        Tilt.new(File.expand_path(path)).render(self, { reason: reason }.merge(@options))
      end

      def self.extension
        'html.erb'
      end

    end
  end
end
