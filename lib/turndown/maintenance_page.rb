# frozen_string_literal: true

require 'pathname'

module Turndown
  module MaintenancePage
    def self.all
      @all ||= []
    end

    # Select the best page class for the given Rack env.
    # JSON pages are served when the Accept header signals JSON and does not include text/html.
    # Falls back to a custom page if one exists on disk; otherwise uses the configured default.
    def self.best_for(env)
      accept = env['HTTP_ACCEPT'].to_s

      if json_request?(accept)
        custom = all.find { |page| json_page?(page) && File.exist?(page.new.custom_path) }
        custom || Turndown::MaintenancePage::JSON
      else
        custom = all.find { |page| html_page?(page) && File.exist?(page.new.custom_path) }
        custom || Turndown.config.default_maintenance_page
      end
    end

    def self.json_request?(accept)
      Turndown::MaintenancePage::JSON.media_types.any? { |type| accept.include?(type) } &&
        !accept.include?('text/html')
    end
    private_class_method :json_request?

    def self.json_page?(page_class)
      (page_class.media_types & Turndown::MaintenancePage::JSON.media_types).any?
    end
    private_class_method :json_page?

    def self.html_page?(page_class)
      (page_class.media_types & Turndown::MaintenancePage::HTML.media_types).any?
    end
    private_class_method :html_page?

    require 'turndown/maintenance_page/base'
    require 'turndown/maintenance_page/erb'
    require 'turndown/maintenance_page/html'
    require 'turndown/maintenance_page/json'
  end
end
