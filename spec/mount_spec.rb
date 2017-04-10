RSpec.describe Hanami::Router do
  before do
    @router = Hanami::Router.new do
      mount Api::App,                      at: '/api'
      mount Api::App.new,                  at: '/api2'
      mount Backend::App,                  at: '/backend'
      mount ->(env) {[200, {}, ['proc']]}, at: '/proc'
      mount 'dashboard#index',             at: '/dashboard'
    end

    @app = Rack::MockRequest.new(@router)
  end

  [ 'get', 'post', 'delete', 'put', 'patch', 'trace', 'options', 'link', 'unklink' ].each do |verb|
    it "accepts #{ verb } for a class endpoint" do
      expect(@app.request(verb.upcase, '/backend', lint: true).body). to eq('home')
    end

    it "accepts #{ verb } for an instance endpoint when a class is given" do
      expect(@app.request(verb.upcase, '/api', lint: true).body).to eq('home')
    end

    it "accepts #{ verb } for an instance endpoint" do
      expect(@app.request(verb.upcase, '/api2', lint: true).body).to eq('home')
    end

    it "accepts #{ verb } for a proc endpoint" do
     expect(@app.request(verb.upcase, '/proc', lint: true).body).to eq('proc')
    end

    it "accepts #{ verb } for a controller endpoint" do
      expect(@app.request(verb.upcase, '/dashboard', lint: true).body).to eq('dashboard')
    end

    it "accepts sub paths when #{ verb } is requested" do
      expect(@app.request(verb.upcase, '/api/articles', lint: true).body).to eq('articles')
    end

    it "returns 404 when #{ verb } is requested and the app cannot find the resource" do
      expect(@app.request(verb.upcase, '/api/unknown', lint: true).status).to eq(404)
    end
  end
end
