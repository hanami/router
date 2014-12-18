require 'test_helper'

describe Lotus::Router::VERSION do
  it 'exposes version' do
    Lotus::Router::VERSION.must_equal '0.2.0'
  end
end
