ENV['RACK_ENV'] ||= 'test'

Bundler.require

require 'minitest/autorun'

require 'graph-backend'
require 'auth-backend'
require 'rack/client'

require 'graph-client'
