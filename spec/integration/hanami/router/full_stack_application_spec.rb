# frozen_string_literal: true

RSpec.describe "Hanami integration" do
  let(:app) { Rack::MockRequest.new(router) }
  let(:router) do
    Hanami::Router.new(namespace: Travels::Controllers, configuration: Action::Configuration.new("hanami")) do
      get "/dashboard",    to: "journeys#index"
      resources :journeys, only: [:index]
    end
  end

  it "recognizes single endpoint" do
    response = app.get("/dashboard", lint: true)
    expect(response.body).to eq("Hello from Travels::Controllers::Journeys::Index")
  end

  it "recognizes RESTful endpoint" do
    response = app.get("/journeys", lint: true)
    expect(response.body).to eq("Hello from Travels::Controllers::Journeys::Index")
  end
end
