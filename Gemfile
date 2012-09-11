source 'https://rubygems.org'
source "https://user:#{ENV['QS_GEMS_PASSWORD']}@privategems.herokuapp.com/"

# Specify your gem's dependencies in graph-client.gemspec
gemspec

# gem 'service-client', path: '../service-client'

group :development, :test do
  # gem 'graph-backend', path: '../graph-backend'
  gem 'graph-backend', '0.0.3'

  gem 'uuid'
  gem 'rack-test'
  gem 'rake'
end
