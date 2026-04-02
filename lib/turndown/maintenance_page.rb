require 'pathname'
module Turndown
  module MaintenancePage
    require 'rack/accept'

    def self.all
      @all ||= []
    end

    def self.best_for(env)
      request = Rack::Accept::Request.new(env)

      all_types = all.map(&:media_types).flatten
      best_type = request.best_media_type(all_types)
      best = all.find { |page| page.media_types.include?(best_type) && File.exist?(page.new.custom_path) }
      best || Turndown.config.default_maintenance_page
    end

    require 'turndown/maintenance_page/base'
    require 'turndown/maintenance_page/erb'
    require 'turndown/maintenance_page/html'
    require 'turndown/maintenance_page/json'
  end
end
