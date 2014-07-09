source 'https://rubygems.org'
gemspec

if ENV['TRAVIS']
  gem 'lotus-utils'
else
  gem 'byebug',      require: false, platforms: :mri if RUBY_VERSION >= '2.1.0'
  gem 'yard',        require: false
  gem 'lotus-utils', require: false, github: 'lotus/utils'
end

gem 'simplecov', require: false
gem 'coveralls', require: false
