require 'rack'
require 'turndown'

class Rack::Turndown
  def initialize(app, config={})
    @app = app

    Turndown.config.update config

    if config[:app_root].nil? && app.respond_to?(:app_root)
      Turndown.config.app_root = app.app_root
    end
  end

  def call(env)
    request = Turndown::Request.new(env)
    settings = Turndown::MaintenanceFile.find

    if settings && !request.allowed?(settings)
      page_class = Turndown::MaintenancePage.best_for(env)
      page = page_class.new(settings.reason, env: env)

      page.rack_response(settings.response_code, settings.retry_after)
    else
      @app.call(env)
    end
  end
end
