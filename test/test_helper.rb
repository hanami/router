require 'rubygems'
require 'bundler/setup'

if ENV['COVERAGE'] == 'true'
  require 'simplecov'
  require 'coveralls'

  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
    Coveralls::SimpleCov::Formatter
  ]

  SimpleCov.start do
    command_name 'test'

    add_filter 'test'
  end
end

if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start do
    add_filter 'test'
    command_name 'Mintest'
  end
end

require 'minitest/autorun'
require 'fixtures'
$:.unshift 'lib'
require 'lotus-router'

Rack::MockResponse.class_eval do
  def equal?(other)
    other = Rack::MockResponse.new(*other)

    status    == other.status  &&
      headers == other.headers &&
      body    == other.body
  end
end

Lotus::Router.class_eval do
  def reset!
    @router.reset!
  end
end
