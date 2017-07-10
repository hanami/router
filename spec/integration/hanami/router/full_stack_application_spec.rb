RSpec.describe 'Hanami integration' do
  before do
    @router_container = Hanami::Router.new(scheme: 'https', host: 'hanami.test', port: 443) do
      mount Dashboard::Index, at: '/dashboard'
      mount Backend::App, at: '/backend'
    end

    @routes = Hanami::Router.new(namespace: Travels::Controllers) do
      get '/dashboard',    to: 'journeys#index'
      resources :journeys, only: [:index]
    end

    @app = Rack::MockRequest.new(@routes)
  end

  it 'recognizes single endpoint' do
    response = @app.get('/dashboard', lint: true)
    expect(response.body).to eq('Hello from Travels::Controllers::Journeys::Index')
  end

  it 'recognizes RESTful endpoint' do
    response = @app.get('/journeys', lint: true)
    expect(response.body).to eq('Hello from Travels::Controllers::Journeys::Index')
  end
end
