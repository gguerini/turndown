# frozen_string_literal: true

require 'turndown'
require 'rack/turndown'
require 'rails'

module Turndown
  class Engine < Rails::Engine
    initializer 'turndown.add_to_middleware_stack' do |app|
      app.config.middleware.use(Rack::Turndown) unless Turndown.config.skip_middleware
    end
  end
end
