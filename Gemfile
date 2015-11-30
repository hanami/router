source 'https://rubygems.org'
gemspec

if !ENV['TRAVIS']
  gem 'byebug', require: false, platforms: :mri if RUBY_VERSION >= '2.1.0'
  gem 'yard',   require: false
end

gem 'lotus-utils', '~> 0.6', require: false, github: 'lotus/utils', branch: 'string-rsub'
gem 'simplecov',             require: false
gem 'coveralls',             require: false
