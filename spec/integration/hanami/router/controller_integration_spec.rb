# frozen_string_literal: true

RSpec.describe "Hanami::Controller integration" do
  let(:app) { Rack::MockRequest.new(router) }
  let(:router) do
    Hanami::Router.new(configuration: Action::Configuration.new("credit_cards")) do
      get "/ccs", to: "credit_cards#index"
      resources :credit_cards, only: [:index]
    end
  end

  it "recognizes single endpoint (with naming convention)" do
    response = app.get("/ccs", lint: true)
    expect(response.body).to eq("Hello from CreditCards::Index")
  end

  it "recognizes RESTful endpoint" do
    response = app.get("/credit_cards", lint: true)
    expect(response.body).to eq("Hello from CreditCards::Index")
  end
end
