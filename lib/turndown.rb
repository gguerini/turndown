# frozen_string_literal: true

module Turndown
  require 'turndown/configuration'
  require 'turndown/support/list_parser'
  require 'turndown/maintenance_file'
  require 'turndown/maintenance_page'
  require 'turndown/request'
  require 'turndown/engine' if defined? Rails

  def self.configure
    yield config
  end

  def self.config
    @config ||= Configuration.new
  end
end
