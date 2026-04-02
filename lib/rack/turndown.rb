# frozen_string_literal: true

require 'rack'
require 'turndown'

class Rack::Turndown
  def initialize(app, config = {})
    @app = app

    Turndown.config.update config

    if config[:app_root].nil? && app.respond_to?(:app_root)
      Turndown.config.app_root = app.app_root
    end
  end

  def call(env)
    state = active_maintenance_state

    if state.nil?
      @app.call(env)
    else
      request = Turndown::Request.new(env)
      if request.allowed?(state)
        @app.call(env)
      else
        page_class = Turndown::MaintenancePage.best_for(env)
        page = page_class.new(state.reason, env: env)
        page.rack_response(state.response_code, state.retry_after)
      end
    end
  end

  private

  def active_maintenance_state
    Turndown.config.providers.each do |provider_class|
      state = provider_class.new.active_state
      return state unless state.nil?
    end
    nil
  end
end
