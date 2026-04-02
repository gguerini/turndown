lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'turndown/version'

spec = Gem::Specification.new do |s|
  s.name                  = 'turndown'
  s.version               = Turndown::VERSION
  s.summary               = 'Rack maintenance mode middleware for Rails and Ruby apps'
  s.description           = 'Turndown puts your Rack/Rails application into maintenance mode. Supports ENV-var activation for containerized deployments and file-based activation for single-instance apps.'
  s.files                 = Dir['README.*', 'MIT-LICENSE', 'rails/*.rb', 'config/**/*.rb', 'lib/**/*.rb', 'lib/tasks/*.rake', 'public/*']
  s.require_path          = 'lib'
  s.author                = 'Adam Crownoble'
  s.email                 = 'adam@codenoble.com'
  s.homepage              = 'https://github.com/gguerini/turndown'
  s.license               = 'MIT'
  s.required_ruby_version = '>= 3.1'
  s.metadata = {
    'source_code_uri'       => 'https://github.com/gguerini/turndown',
    'changelog_uri'         => 'https://github.com/gguerini/turndown/blob/master/CHANGELOG.md',
    'rubygems_mfa_required' => 'true'
  }

  s.add_dependency('tilt', '~> 2.0')
  s.add_dependency('rack', '>= 2.2', '< 4')

  s.add_development_dependency('rack-test',      '~> 2.0')
  s.add_development_dependency('rspec',           '~> 3.0')
  s.add_development_dependency('simplecov',       '~> 0.22')
  s.add_development_dependency('rubocop',         '~> 1.60')
  s.add_development_dependency('rubocop-rspec',   '~> 2.0')
end
