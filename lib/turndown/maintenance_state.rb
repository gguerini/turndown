# frozen_string_literal: true

module Turndown
  # Read-only value object representing settled maintenance settings.
  # Returned by both Provider::Env and Provider::File; consumed by the
  # middleware and MaintenancePage rendering.
  class MaintenanceState
    attr_reader :reason, :allowed_paths, :allowed_ips, :response_code, :retry_after

    def initialize(reason:, allowed_paths:, allowed_ips:, response_code:, retry_after:)
      @reason        = reason
      @allowed_paths = Array(allowed_paths)
      @allowed_ips   = Array(allowed_ips)
      @response_code = response_code.to_i
      @retry_after   = retry_after
    end

    # Build a MaintenanceState from config defaults, with optional overrides.
    # nil override values fall back to the configured default.
    def self.from_defaults(overrides = {})
      cfg = Turndown.config
      new(
        reason:        overrides[:reason]        || cfg.default_reason,
        allowed_paths: overrides[:allowed_paths] || cfg.default_allowed_paths,
        allowed_ips:   overrides[:allowed_ips]   || cfg.default_allowed_ips,
        response_code: overrides[:response_code] || cfg.default_response_code,
        retry_after:   overrides[:retry_after]   || cfg.default_retry_after
      )
    end
  end
end
