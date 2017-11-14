# frozen_string_literal: true

RSpec.describe "Hanami::Controller integration" do
  before do
    @routes = Hanami::Router.new do
      get "/payments", to: CreditCards::Index
      get "/ccs",      to: "credit_cards#index"
      resources :credit_cards, only: [:index]
    end

    @app = Rack::MockRequest.new(@routes)
  end

  it "recognizes single endpoint (as class)" do
    response = @app.get("/payments", lint: true)
    expect(response.body).to eq("Hello from CreditCards::Index")
  end

  it "recognizes single endpoint (with naming convention)" do
    response = @app.get("/ccs", lint: true)
    expect(response.body).to eq("Hello from CreditCards::Index")
  end

  it "recognizes RESTful endpoint" do
    response = @app.get("/credit_cards", lint: true)
    expect(response.body).to eq("Hello from CreditCards::Index")
  end
end
