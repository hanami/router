source 'https://rubygems.org'
gemspec

unless ENV['TRAVIS']
  gem 'byebug',      require: false, platforms: :ruby if RUBY_VERSION >= '2.1.0'
  gem 'yard',        require: false
  gem 'lotus-utils', require: false, github: 'lotus/utils'
else
  gem 'lotus-utils'
end

gem 'simplecov', require: false
gem 'coveralls', require: false
