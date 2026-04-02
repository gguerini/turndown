# frozen_string_literal: true

module Turndown
  module Provider
    # Activates maintenance mode via a YAML file on disk (e.g. tmp/maintenance.yml).
    # Compatible with the existing rake maintenance:start / maintenance:end tasks.
    class File
      def active_state
        maint_file = MaintenanceFile.find
        return nil if maint_file.nil?

        MaintenanceState.new(
          reason:        maint_file.reason,
          allowed_paths: maint_file.allowed_paths,
          allowed_ips:   maint_file.allowed_ips,
          response_code: maint_file.response_code,
          retry_after:   maint_file.retry_after
        )
      end
    end
  end
end
