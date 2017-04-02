require 'rubygems'
require 'bundler/setup'

if ENV['COVERALL']
  require 'coveralls'
  Coveralls.wear!
end

require 'minitest/autorun'
require 'support/generation_test_case'
require 'support/recognition_test_case'
$:.unshift 'lib'
require 'hanami-router'

Rack::MockResponse.class_eval do
  def equal?(other)
    other = Rack::MockResponse.new(*other)

    status    == other.status  &&
      headers == other.headers &&
      body    == other.body
  end
end

Hanami::Router.class_eval do
  def reset!
    @router.reset!
  end
end

require_relative 'fixtures'
