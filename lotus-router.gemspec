# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lotus/router/version'

Gem::Specification.new do |spec|
  spec.name          = 'lotus-router'
  spec.version       = Lotus::Router::VERSION
  spec.authors       = ['Luca Guidi']
  spec.email         = ['me@lucaguidi.com']
  spec.description   = %q{HTTP Router for Lotus}
  spec.summary       = %q{HTTP Router for Lotus}
  spec.homepage      = 'http://lotusrb.org/lotus-router'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = []
  spec.test_files    = spec.files.grep(%r{^(test)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'http_router'

  spec.add_development_dependency 'bundler',  '~> 1.3'
  spec.add_development_dependency 'minitest', '~> 5'
  spec.add_development_dependency 'rake'
end
