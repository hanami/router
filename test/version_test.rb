require 'test_helper'

describe Hanami::Router::VERSION do
  it 'exposes version' do
    Hanami::Router::VERSION.must_equal '0.8.1'
  end
end
