source 'https://rubygems.org'
gemspec

if !ENV['TRAVIS']
  gem 'byebug', require: false, platforms: :mri if RUBY_VERSION >= '2.1.0'
  gem 'yard',   require: false
end

gem 'lotus-utils', '~> 0.6',  require: false, github: 'lotus/utils', branch: '0.6.x'
gem 'simplecov',   '~> 0.11', require: false
gem 'coveralls',              require: false
