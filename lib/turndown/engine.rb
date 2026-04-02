require 'turndown'
require 'rack/turndown'
require 'rails'

# For Rails 3
if defined? Rails::Engine
  module Turndown
    class Engine < Rails::Engine
      initializer 'turndown.add_to_middleware_stack' do |app|
        unless Turndown.config.skip_middleware
          app.config.middleware.use(Rack::Turndown)
        end
      end
    end
  end
end
