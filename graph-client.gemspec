# -*- encoding: utf-8 -*-
require File.expand_path('../lib/graph-client/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Thorben Schröder"]
  gem.email         = ["info@thorbenschroeder.de"]
  gem.description   = %q{Client to the graph-backend.}
  gem.summary       = %q{Client to the graph-backend.}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "graph-client"
  gem.require_paths = ["lib"]
  gem.version       = Graph::Client::VERSION
end
