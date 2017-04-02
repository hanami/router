RSpec.describe Hanami::Router do
  before do
    @router = Hanami::Router.new
  end

  describe '#redirect' do
    it 'recognizes string endpoint' do
      endpoint = ->(env) { [200, {}, ['Redirect destination!']] }
      @router.get('/redirect_destination', to: endpoint)
      @router.redirect('/redirect', to: '/redirect_destination')

      env = Rack::MockRequest.env_for('/redirect')
      status, headers, _ = @router.call(env)

      expect(status).to eq(301)
      expect(headers['Location']).to eq('/redirect_destination')
    end

    it 'recognizes string endpoint with custom http code' do
      endpoint = ->(env) { [200, {}, ['Redirect destination!']] }
      @router.get('/redirect_destination', to: endpoint)
      @router.redirect('/redirect', to: '/redirect_destination', code: 302)

      env = Rack::MockRequest.env_for('/redirect')
      status, headers, _ = @router.call(env)

      expect(status).to eq(302)
      expect(headers['Location']).to eq('/redirect_destination')
    end
  end
end
