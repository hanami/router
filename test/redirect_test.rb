require 'test_helper'

describe Lotus::Router do
  before do
    @router = Lotus::Router.new
  end

  describe '#redirect' do
    it 'recognize endpoint' do
      response = [200, {}, ['Redirect destination!']]
      endpoint = ->(env) { response }
      @router.get('/redirect_destination', to: endpoint)

      env = Rack::MockRequest.env_for('/redirect')

      @router.get('/redirect', to: @router.redirect('/redirect_destination'))
      @router.call(env).must_equal response
    end

    it 'raises error when the given redirect endpoint cannot be found' do
      -> {
        @router.get('/redirect_to_unknown_route', to: @router.redirect('/unknown_route'))
      }.must_raise ArgumentError
    end
  end
end
