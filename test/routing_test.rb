require 'test_helper'

describe Lotus::Router do
  before do
    @router = Lotus::Router.new
  end

  describe '#get' do
    describe 'path recognition' do
      it 'recognize fixed string' do
        response = [200, {}, ['Fixed!']]
        endpoint = ->(env) { response }
        env      = Rack::MockRequest.env_for('/lotus')

        @router.get('/lotus', to: endpoint)
        @router.call(env).must_equal response
      end

      it 'recognize moving parts string' do
        response = [200, {}, ['Moving!']]
        endpoint = ->(env) { response }
        env      = Rack::MockRequest.env_for('/lotus/23')

        @router.get('/lotus/:id', to: endpoint)
        @router.call(env).must_equal response
      end

      it 'recognize globbing string' do
        response = [200, {}, ['Globbing!']]
        endpoint = ->(env) { response }
        env      = Rack::MockRequest.env_for('/lotus/all')

        @router.get('/lotus/*', to: endpoint)
        @router.call(env).must_equal response
      end

      it 'recognize format string' do
        response = [200, {}, ['Globbing!']]
        endpoint = ->(env) { response }
        env      = Rack::MockRequest.env_for('/lotus/all.json')

        @router.get('/lotus/:id(.:format)', to: endpoint)
        @router.call(env).must_equal response
      end
    end
  end
end
