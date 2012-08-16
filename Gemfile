source 'https://rubygems.org'

# Specify your gem's dependencies in graph-client.gemspec
gemspec

gem 'service-client', path: '../service-client'
# gem 'service-client', git: 'git@github.com:quarter-spiral/service-client.git', :tag => 'release-0.0.4'

gem 'commander'

group :development, :test do
  gem 'graph-backend', path: '../graph-backend'
  # gem 'graph-backend', git: 'git@github.com:quarter-spiral/graph-backend.git', tag: 'release-0.0.1'

  gem 'uuid'
  gem 'rack-test'
  gem 'rake'
end
