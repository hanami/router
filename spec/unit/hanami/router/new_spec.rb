# frozen_string_literal: true

RSpec.describe Hanami::Router do
  describe "#initialize" do
    before do
      class MockRoute
      end
    end

    let(:app) { Rack::MockRequest.new(router) }
    let(:endpoint) { ->(_) { [200, {}, [""]] } }
    let(:router) do
      e = endpoint

      described_class.new do
        root                to: e
        get "/route",       to: e
        get "/named_route", to: e, as: :named_route
        resource  "avatar"
        resources "flowers"
        namespace "admin" do
          get "/dashboard", to: e
        end
      end
    end

    it "returns instance of Hanami::Router with empty block" do
      router = Hanami::Router.new {}
      expect(router).to be_instance_of(Hanami::Router)
    end

    it "returns frozen instance" do
      expect(router).to be_frozen
    end

    it "evaluates routes passed from Hanami::Router.define" do
      routes = Hanami::Router.define { post "/domains", to: ->(_env) { [201, {}, ["Domain Created"]] } }
      router = Hanami::Router.new(&routes)

      app      = Rack::MockRequest.new(router)
      response = app.post("/domains", lint: true)

      expect(response.status).to eq(201)
      expect(response.body).to eq("Domain Created")
    end

    it "returns instance of Hanami::Router" do
      expect(router).to be_instance_of(Hanami::Router)
    end

    it "sets options" do
      router = Hanami::Router.new(scheme: "https") do
        root to: ->(env) {}
      end

      expect(router.url(:root)).to match("https")
    end

    it "checks if there are defined routes" do
      router = Hanami::Router.new
      expect(router.defined?).to be false

      router = Hanami::Router.new { get "/", to: ->(env) {} }
      expect(router.defined?).to be true
    end

    it "recognizes root" do
      expect(app.get("/", lint: true).status).to eq(200)
    end

    it "recognizes path" do
      expect(app.get("/route", lint: true).status).to eq(200)
    end

    it "recognizes named path" do
      expect(app.get("/named_route", lint: true).status).to eq(200)
    end

    it "recognizes resource" do
      expect(app.get("/avatar", lint: true).status).to eq(200)
    end

    it "recognizes resources" do
      expect(app.get("/avatar", lint: true).status).to eq(200)
    end

    it "recognizes namespaced path" do
      expect(app.get("/admin/dashboard", lint: true).status).to eq(200)
    end
  end
end
