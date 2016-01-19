require 'test_helper'

describe Hanami::Router do
  describe '.define' do
    it 'returns block as it is' do
      routes = -> { get '/', to: ->(env) {[200, {}, ['OK']]} }
      Hanami::Router.define(&routes).must_equal routes
    end
  end
end
