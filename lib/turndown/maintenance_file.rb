# frozen_string_literal: true

require 'yaml'
require 'fileutils'

module Turndown
  class MaintenanceFile
    attr_reader :path

    SETTINGS = [:reason, :allowed_paths, :allowed_ips, :response_code, :retry_after]
    attr_reader(*SETTINGS)

    def initialize(path)
      @path = path
      @reason = Turndown.config.default_reason
      @allowed_paths = Turndown.config.default_allowed_paths
      @allowed_ips = Turndown.config.default_allowed_ips
      @response_code = Turndown.config.default_response_code
      @retry_after = Turndown.config.default_retry_after

      import_yaml if exists?
    end

    def exists?
      File.exist? path
    end

    def to_h
      SETTINGS.each_with_object({}) do |att, hash|
        hash[att] = send(att)
      end
    end

    def to_yaml(key_mapper = :to_s)
      to_h.each_with_object({}) { |(key, val), hash|
        hash[key.send(key_mapper)] = val
      }.to_yaml
    end

    def write
      FileUtils.mkdir_p(dir_path) unless Dir.exist? dir_path

      File.open(path, 'w') do |file|
        file.write to_yaml
      end
    end

    def delete
      File.delete(path) if exists?
    end

    def import(hash)
      SETTINGS.map(&:to_s).each do |att|
        self.send(:"#{att}=", hash[att]) unless hash[att].nil?
      end

      true
    end
    alias :import_env_vars :import

    # Find the first MaintenanceFile that exists
    def self.find
      path = named_paths.values.find { |p| File.exist? p }
      self.new(path) if path
    end

    def self.named(name)
      path = named_paths[name.to_sym]
      self.new(path) unless path.nil?
    end

    def self.default
      self.new(named_paths.values.first)
    end

    private

    def retry_after=(value)
      @retry_after = value
    end

    def reason=(reason)
      @reason = reason.to_s
    end

    def allowed_paths=(paths)
      @allowed_paths = paths.is_a?(String) ? Support::ListParser.call(paths) : paths
    end

    def allowed_ips=(ips)
      @allowed_ips = ips.is_a?(String) ? Support::ListParser.call(ips) : ips
    end

    def response_code=(code)
      @response_code = code.to_i
    end

    def dir_path
      File.dirname(path)
    end

    def import_yaml
      import(YAML.safe_load(File.read(path), permitted_classes: [], symbolize_names: false) || {})
    end

    def self.named_paths
      Turndown.config.named_maintenance_file_paths
    end
  end
end
