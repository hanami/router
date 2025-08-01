# frozen_string_literal: true

RSpec.describe "Pass on response" do
  let(:app) { Rack::MockRequest.new(routes) }
  let(:routes) do
    # Hoist back into RSpec context to use "rack_headers" helper
    action = ->(*) { [200, rack_headers({"Content-Length" => "2"}), ["OK"]] }
    Hanami::Router.new { get "/", to: action }
  end

  it "is successful" do
    response = app.get("/", lint: true)
    expect(response.status).to eq(200)
  end
end
