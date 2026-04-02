# frozen_string_literal: true

module Turndown
  module Provider
    # Activates maintenance mode via environment variables.
    # Reads ENV on every call — no caching — so changes take effect immediately
    # without restarting the process (useful for containerized deployments).
    #
    # Supported variables (prefix defaults to TURNDOWN, configurable via config.env_prefix):
    #   {PREFIX}_ENABLED        — truthy value (1, true, yes, on) activates maintenance mode
    #   {PREFIX}_REASON         — custom maintenance message
    #   {PREFIX}_ALLOWED_IPS    — comma-separated IPs or CIDRs
    #   {PREFIX}_ALLOWED_PATHS  — comma-separated regex paths (backslash-escaped commas preserved)
    #   {PREFIX}_RESPONSE_CODE  — HTTP status code
    #   {PREFIX}_RETRY_AFTER    — Retry-After header value (seconds)
    class Env
      TRUTHY_VALUES = %w[1 true yes on].freeze

      def active_state
        return nil unless TRUTHY_VALUES.include?(env_val(:enabled)&.downcase)

        MaintenanceState.from_defaults(
          reason:        env_val(:reason),
          allowed_paths: parse_list(env_val(:allowed_paths)),
          allowed_ips:   parse_list(env_val(:allowed_ips)),
          response_code: env_val(:response_code)&.to_i,
          retry_after:   env_val(:retry_after)
        )
      end

      private

      def env_val(key)
        ENV["#{Turndown.config.env_prefix}_#{key.to_s.upcase}"]
      end

      def parse_list(value)
        return nil if value.nil?

        Support::ListParser.call(value)
      end
    end
  end
end
