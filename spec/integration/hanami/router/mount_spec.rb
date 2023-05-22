require "rack/head"

RSpec.describe Hanami::Router do
  let(:router) do
    Hanami::Router.new do
      mount Api::App.new,                  at: "/api"
      mount Backend::App,                  at: "/backend"
      mount ->(*) { [200, {"Content-Length" => "4"}, ["proc"]] }, at: "/proc"
      mount ->(*) { [200, {"Content-Length" => "8"}, ["trailing"]] }, at: "/trailing/"

      get "/*any", to: ->(*) { [200, {"Content-Length" => "4"}, ["home"]] }
    end
  end

  shared_examples "mountable rack endpoint" do
    it "accepts an instance endpoint" do
      expect(app.request(verb.upcase, "/api", lint: true).body).to eq(body_for("home", verb))
    end

    it "accepts for a class endpoint" do
      expect(app.request(verb.upcase, "/backend", lint: true).body).to eq(body_for("home", verb))
    end

    it "accepts for a proc endpoint" do
      expect(app.request(verb.upcase, "/proc", lint: true).body).to eq(body_for("proc", verb))
    end

    it "accepts for a route using trailing slash" do
      expect(app.request(verb.upcase, "/trailing/", lint: true).body).to eq(body_for("trailing", verb))
    end

    it "accepts sub paths when is requested" do
      expect(app.request(verb.upcase, "/api/articles", lint: true).body).to eq(body_for("articles", verb))
    end

    it "returns 404 when is requested and the app cannot find the resource" do
      expect(app.request(verb.upcase, "/api/unknown", lint: true).status).to eq(404)
    end
  end

  RSpec::Support::HTTP.mountable_verbs.each do |http_verb|
    context http_verb.upcase do
      let(:app)  { Rack::MockRequest.new(router) }
      let(:verb) { http_verb }

      it_behaves_like "mountable rack endpoint"
    end
  end

  context "HEAD" do
    let(:app) { Rack::MockRequest.new(Rack::Head.new(router)) }
    let(:verb) { "head" }

    it_behaves_like "mountable rack endpoint"
  end

  context "glob routes" do
    let(:app) { Rack::MockRequest.new(router) }

    it "falls back to glob" do
      expect(app.request("GET", "/foo", lint: true).status).to eq(200)
    end
  end
end
