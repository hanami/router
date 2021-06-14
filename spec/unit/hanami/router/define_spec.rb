# frozen_string_literal: true

RSpec.describe Hanami::Router do
  describe ".define" do
    it "returns block as it is" do
      routes = -> { get "/", to: ->(*) { [200, {}, ["OK"]] } }
      expect(Hanami::Router.define(&routes)).to eq(routes)
    end
  end
end
