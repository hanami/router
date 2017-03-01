require 'test_helper'

describe Hanami::Router::VERSION do
  it 'exposes version' do
    Hanami::Router::VERSION.must_equal '1.0.0.beta2'
  end
end
