require 'bundler/setup'
require 'simplecov'
require 'simplecov-summary'
SimpleCov.start 'rails'
ENV["RAILS_ENV"] ||= 'test'
require 'rack/test'
require 'rspec'
require 'rspec/its'
require 'rack/turndown'
require 'fixtures/test_app'
# require "codeclimate-test-reporter"
formatters = [SimpleCov::Formatter::SummaryFormatter,SimpleCov::Formatter::HTMLFormatter]

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new(formatters)

SimpleCov.start :rails do
  add_filter 'lib/tasks'
  add_filter ['lib/turndown/version.rb', 'lib/turndown.rb', 'lib/turndown/rake_tasks.rb', 'lib/turndown/engine.rb']
   at_exit do
     SimpleCov.result.format!
   end
 end

RSpec.configure do |config|
  config.include Rack::Test::Methods
end
