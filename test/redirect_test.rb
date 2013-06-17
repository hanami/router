require 'test_helper'

describe Lotus::Router do
  before do
    @router = Lotus::Router.new
  end

  describe '#redirect' do
    it 'recognizes string endpoint' do
      endpoint = ->(env) { [200, {}, ['Redirect destination!']] }
      @router.get('/redirect_destination', to: endpoint)
      @router.redirect('/redirect', to: '/redirect_destination')

      env = Rack::MockRequest.env_for('/redirect')
      status, headers, _ = @router.call(env)

      status.must_equal 302
      headers['Location'].must_equal '/redirect_destination'
    end

    it 'recognizes string endpoint with custom http code' do
      endpoint = ->(env) { [200, {}, ['Redirect destination!']] }
      @router.get('/redirect_destination', to: endpoint)
      @router.redirect('/redirect', to: '/redirect_destination', code: 301)

      env = Rack::MockRequest.env_for('/redirect')
      status, headers, _ = @router.call(env)

      status.must_equal 301
      headers['Location'].must_equal '/redirect_destination'
    end
  end
end
