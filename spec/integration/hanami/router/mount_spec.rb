# frozen_string_literal: true

RSpec.describe Hanami::Router do
  let(:router) do
    Hanami::Router.new do
      mount Api::App.new,                  at: "/api2"
      mount Api::App,                      at: "/api"
      mount Backend::App,                  at: "/backend"
      mount ->(_) { [200, {}, ["proc"]] }, at: "/proc"
    end
  end

  let(:app) { Rack::MockRequest.new(router) }

  RSpec::Support::HTTP.verbs.each do |verb|
    it "accepts #{verb} for a class endpoint" do
      expect(app.request(verb.upcase, "/backend", lint: true).body).to eq(body_for("home", verb))
    end

    it "accepts #{verb} for an instance endpoint when a class is given" do
      expect(app.request(verb.upcase, "/api", lint: true).body).to eq(body_for("home", verb))
    end

    it "accepts #{verb} for an instance endpoint" do
      expect(app.request(verb.upcase, "/api2", lint: true).body).to eq(body_for("home", verb))
    end

    it "accepts #{verb} for a proc endpoint" do
      expect(app.request(verb.upcase, "/proc", lint: true).body).to eq(body_for("proc", verb))
    end

    it "accepts sub paths when #{verb} is requested" do
      expect(app.request(verb.upcase, "/api/articles", lint: true).body).to eq(body_for("articles", verb))
    end

    it "returns 404 when #{verb} is requested and the app cannot find the resource" do
      expect(app.request(verb.upcase, "/api/unknown", lint: true).status).to eq(404)
    end
  end
end
