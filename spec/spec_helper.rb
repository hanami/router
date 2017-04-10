if ENV['COVERALL']
  require 'coveralls'
  Coveralls.wear!
end

require 'hanami/utils'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.filter_run_when_matching :focus
  config.disable_monkey_patching!

  config.warnings = true

  config.default_formatter = 'doc' if config.files_to_run.one?

  config.profile_examples = 10

  config.order = :random
  Kernel.srand config.seed
end

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

Hanami::Utils.require!("spec/support")