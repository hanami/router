# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hanami/router/version'

Gem::Specification.new do |spec|
  spec.name          = 'hanami-router'
  spec.version       = Hanami::Router::VERSION
  spec.authors       = ['Luca Guidi']
  spec.email         = ['me@lucaguidi.com']
  spec.description   = %q{Rack compatible HTTP router for Ruby}
  spec.summary       = %q{Rack compatible HTTP router for Ruby and Hanami}
  spec.homepage      = 'http://hanamirb.org'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -- lib/* CHANGELOG.md LICENSE.md README.md hanami-router.gemspec`.split($/)
  spec.executables   = []
  spec.test_files    = spec.files.grep(%r{^(test)/})
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.3.0'

  spec.add_dependency 'rack',         '~> 2.0'
  spec.add_dependency 'http_router',  '0.11.2'
  spec.add_dependency 'hanami-utils', '~> 1.3'

  spec.add_development_dependency 'bundler',   '>= 1.6', '< 3'
  spec.add_development_dependency 'rake',      '~> 13'
  spec.add_development_dependency 'rack-test', '~> 1.0'
  spec.add_development_dependency 'rspec',     '~> 3.7'
end
