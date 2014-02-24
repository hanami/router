source 'http://rubygems.org'
gemspec

unless ENV['TRAVIS']
  gem 'debugger',    require: false, platforms: :ruby if RUBY_VERSION == '2.1.0'
  gem 'yard',        require: false
  gem 'lotus-utils', require: false, path: '../lotus-utils'
end

gem 'simplecov', require: false
gem 'coveralls', require: false
