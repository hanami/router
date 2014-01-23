source 'http://rubygems.org'
gemspec

unless ENV['TRAVIS']
  gem 'debugger',    require: false, platforms: :ruby
  gem 'yard',        require: false
  gem 'simplecov',   require: false
  gem 'lotus-utils', require: false, path: '../lotus-utils'
end

gem 'coveralls', require: false
