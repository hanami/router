RSpec.describe 'Hanami middleware integration' do
  before do
    @routes = Hanami::Router.new(namespace: Web::Controllers) do
      get '/',          to: 'home#index'
      get '/dashboard', to: 'dashboard#index'
    end

    @app = Rack::MockRequest.new(@routes)
  end

  it 'action with middleware' do
    response = @app.get('/', lint: true)
    expect(response.body).to eq('Hello from Web::Controllers::Home::Index')
    expect(response.status).to eq(200)
    expect(response.headers.fetch('X-Middleware')).to eq('CALLED')
  end

  it 'action without middleware' do
    response = @app.get('/dashboard', lint: true)
    expect(response.body).to eq('Hello from Web::Controllers::Dashboard::Index')
    expect(response.status).to eq(200)
    expect(response.headers['X-Middleware']).to be_nil
  end
end
