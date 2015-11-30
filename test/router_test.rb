require 'test_helper'

describe Lotus::Router do
  describe '.define' do
    it 'returns block as it is' do
      routes = -> { get '/', to: ->(env) {[200, {}, ['OK']]} }
      Lotus::Router.define(&routes).must_equal routes
    end
  end
end
