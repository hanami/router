# frozen_string_literal: true

RSpec.describe Hanami::Router do
  before do
    @router = Hanami::Router.new { get "/", to: ->(env) {} }
    @app    = Rack::MockRequest.new(@router)
  end

  it "returns 404 for unknown path" do
    expect(@app.get("/unknown", lint: true).status).to eq(404)
  end

  it "returns 405 for unacceptable HTTP method" do
    expect(@app.post("/", lint: true).status).to eq(405)
  end
end
