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

      it 'accepts a block' do
        response = [200, {}, ['Sinatra!']]
        env      = Rack::MockRequest.env_for('/sinatra')

        @router.get('/sinatra') {|e| response }
        @router.call(env).must_equal response
      end
    end

    describe 'named routes' do
      it 'recognizes by the given symbol' do
        response = [200, {}, ['Named route!']]
        endpoint = ->(env) { response }

        @router.get('/named_route', to: endpoint, as: :get_named_route)

        @router.path(:get_named_route).must_equal '/named_route'
        @router.url(:get_named_route).must_equal  'http://localhost/named_route'
      end

      it 'compiles variables' do
        response = [200, {}, ['Named %route!']]
        endpoint = ->(env) { response }

        @router.get('/named_:var', to: endpoint, as: :get_named_route_var)

        @router.path(:get_named_route_var, var: 'route').must_equal '/named_route'
        @router.url(:get_named_route_var, var: 'route').must_equal  'http://localhost/named_route'
      end

      it 'allows custom url parts' do
        response = [200, {}, ['Named route with custom parts!']]
        endpoint = ->(env) { response }

        router = Lotus::Router.new(scheme: 'https', host: 'lotusrb.org', port: 443)
        router.get('/custom_named_route', to: endpoint, as: :get_custom_named_route)

        router.url(:get_custom_named_route).must_equal  'https://lotusrb.org/custom_named_route'
      end
    end
  end
end
