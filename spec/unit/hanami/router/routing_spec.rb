require "hanami/router/inspector"

RSpec.describe Hanami::Router do
  describe "with an inspector" do
    it "uses original to value to generate the route" do
      resolver = ->(_path, _to) { Class.new }
      inspector = Hanami::Router::Inspector.new

      router = Hanami::Router.new(resolver: resolver, inspector: inspector) do
        get "/", to: "home#index"
      end

      expect(router.inspector.call).to include("home#index")
    end

    it "uses resolved block value to generate the route" do
      inspector = Hanami::Router::Inspector.new

      router = Hanami::Router.new(inspector: inspector) do
        get "/" do
          "Block"
        end
      end

      expect(router.inspector.call).to include("(block)")
    end
  end
end
