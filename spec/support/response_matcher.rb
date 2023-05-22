require "rspec/expectations"

RSpec::Matchers.define :eq_response do |expected|
  match do |actual|
    actual.is_a?(expected.class) &&
      actual.status == expected.status &&
      actual.headers == expected.headers &&
      actual.body == expected.body
  end

  failure_message do |actual|
    <<~MESSAGE
      expected that #{actual}
      would be a #{expected.class} ([#{expected.status.inspect}, #{expected.headers.inspect}, #{expected.body.inspect}])
      got a #{actual.class} ([#{actual.status.inspect}, #{actual.headers.inspect}, #{actual.body.inspect}])
    MESSAGE
  end
end
