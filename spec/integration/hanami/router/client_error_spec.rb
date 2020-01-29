# frozen_string_literal: true

RSpec.describe Hanami::Router do
  let(:router) { described_class.new { get "/", to: ->(env) {} } }
  let(:app) { Rack::MockRequest.new(router) }

  it "returns 404 for unknown path" do
    expect(app.get("/unknown", lint: true).status).to eq(404)
  end

  it "returns 405 for unacceptable HTTP method" do
    expect(app.post("/", lint: true).status).to eq(405)
  end
end
