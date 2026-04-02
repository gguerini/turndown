require 'bundler/setup'
require 'simplecov'

SimpleCov.start do
  add_filter 'lib/tasks'
  add_filter %w[lib/turndown/version.rb lib/turndown.rb lib/turndown/rake_tasks.rb lib/turndown/engine.rb]
  minimum_coverage 90
end

ENV['RAILS_ENV'] ||= 'test'
require 'rack/test'
require 'rspec'
require 'rack/turndown'
require 'fixtures/test_app'

RSpec.configure do |config|
  config.include Rack::Test::Methods

  config.after(:each) do
    Turndown.instance_variable_set(:@config, nil)
  end
end
