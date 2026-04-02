# frozen_string_literal: true

require 'pathname'

module Turndown
  class Configuration
    SETTINGS = %i[
      app_root named_maintenance_file_paths maintenance_pages_path default_maintenance_page
      default_reason default_allowed_ips default_allowed_paths default_response_code
      default_retry_after skip_middleware env_prefix providers
    ].freeze

    SETTINGS.each do |setting|
      attr_accessor setting
    end

    def initialize
      @skip_middleware              = false
      @app_root                     = '.'
      @named_maintenance_file_paths = { default: app_root.join('tmp', 'maintenance.yml').to_s }
      @maintenance_pages_path       = app_root.join('public').to_s
      @default_maintenance_page     = Turndown::MaintenancePage::HTML
      @default_reason               = "The site is temporarily down for maintenance.\nPlease check back soon."
      @default_allowed_paths        = []
      @default_allowed_ips          = []
      @default_response_code        = 503
      @default_retry_after          = 7200 # 2 hours by default
      @env_prefix                   = 'TURNDOWN'
      @providers                    = [Turndown::Provider::Env, Turndown::Provider::File]
    end

    def app_root
      Pathname.new(@app_root.to_s)
    end

    def named_maintenance_file_paths=(named_paths)
      @named_maintenance_file_paths = named_paths.transform_keys(&:to_sym)
    end

    def update(settings_hash)
      settings_hash.each do |setting, value|
        raise ArgumentError, "invalid setting: #{setting}" unless SETTINGS.include?(setting.to_sym)

        public_send("#{setting}=", value)
      end
    end
  end
end
