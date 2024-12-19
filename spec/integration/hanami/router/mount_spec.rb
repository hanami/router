# frozen_string_literal: true

require "rack/head"

RSpec.describe Hanami::Router do
  let(:router) do
    Hanami::Router.new do
      mount Api::App.new,                  at: "/api"
      mount Backend::App,                  at: "/backend"
      mount ->(*) { [200, {"content-length" => "4"}, ["proc"]] }, at: "/proc"
      mount ->(*) { [200, {"content-length" => "8"}, ["trailing"]] }, at: "/trailing/"
      mount Api::App.new, at: "/"
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

    it "accepts paths for mounted apps at the root" do
      expect(app.request(verb.upcase, "/articles", lint: true).body).to eq(body_for("articles", verb))
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
    let(:router) do
      Hanami::Router.new do
        mount Api::App.new, at: "/api"

        get "/*any", to: ->(*) { [200, {"content-length" => "4"}, ["home"]] }
      end
    end
    let(:app) { Rack::MockRequest.new(router) }

    it "falls back to glob" do
      expect(app.request("GET", "/foo", lint: true).status).to eq(200)
    end

    context "with more-specific glob before root-level mount" do
      let(:router) do
        Hanami::Router.new do
          get "/home/*any", to: ->(*) { [200, {"content-length" => "4"}, ["home"]] }

          mount Api::App.new, at: "/"
        end
      end

      it "respects the glob" do
        response = app.request("GET", "/home/foo", lint: true)

        expect(response.status).to eq(200)
        expect(response.body).to eq("home")
      end
    end
  end
end
