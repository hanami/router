require 'test_helper'

describe Lotus::Router do
  before do
    @router = Lotus::Router.new
    @app    = Rack::MockRequest.new(@router)
  end

  after do
    @router.reset!
  end

  def endpoint(response)
    ->(env) { response }
  end

  [ 'get', 'post', 'delete', 'put', 'patch', 'trace' ].each do |verb|

    describe "##{ verb }" do
      describe 'path recognition' do
        it 'recognize fixed string' do
          response = [200, {}, ['Fixed!']]
          @router.send(verb, '/lotus', to: endpoint(response))

          response.must_be_same_as @app.request(verb.upcase, '/lotus')
        end

        it 'recognize moving parts string' do
          response = [200, {}, ['Moving!']]
          @router.send(verb, '/lotus/:id', to: endpoint(response))

          response.must_be_same_as @app.request(verb.upcase, '/lotus/23')
        end

        it 'recognize globbing string' do
          response = [200, {}, ['Globbing!']]
          @router.send(verb, '/lotus/*', to: endpoint(response))

          response.must_be_same_as @app.request(verb.upcase, '/lotus/all')
        end

        it 'recognize format string' do
          response = [200, {}, ['Format!']]
          @router.send(verb, '/lotus/:id(.:format)', to: endpoint(response))

          response.must_be_same_as @app.request(verb.upcase, '/lotus/all.json')
        end

        it 'accepts a block' do
          response = [200, {}, ['Block!']]
          @router.send(verb, '/block') {|e| response }

          response.must_be_same_as @app.request(verb.upcase, '/block')
        end
      end

      describe 'named routes' do
        it 'recognizes by the given symbol' do
          response = [200, {}, ['Named route!']]

          @router.send(verb, '/named_route', to: endpoint(response), as: :"#{ verb }_named_route")

          @router.path(:"#{ verb }_named_route").must_equal '/named_route'
          @router.url(:"#{ verb }_named_route").must_equal  'http://localhost/named_route'
        end

        it 'compiles variables' do
          response = [200, {}, ['Named %route!']]

          @router.send(verb, '/named_:var', to: endpoint(response), as: :"#{ verb }_named_route_var")

          @router.path(:"#{ verb }_named_route_var", var: 'route').must_equal '/named_route'
          @router.url(:"#{ verb }_named_route_var", var: 'route').must_equal  'http://localhost/named_route'
        end

        it 'allows custom url parts' do
          response = [200, {}, ['Named route with custom parts!']]

          router = Lotus::Router.new(scheme: 'https', host: 'lotusrb.org', port: 443)
          router.send(verb, '/custom_named_route', to: endpoint(response), as: :"#{ verb }_custom_named_route")

          router.url(:"#{ verb }_custom_named_route").must_equal 'https://lotusrb.org/custom_named_route'
        end
      end

      describe 'constraints' do
        it 'recognize when called with matching constraints' do
          response = [200, {}, ['Moving with constraints!']]

          @router.send(verb, '/lotus/:id', to: endpoint(response), id: /\d+/)
          response.must_be_same_as @app.request(verb.upcase, '/lotus/23')

          @app.request(verb.upcase, '/lotus/flower').status.must_equal 404
        end
      end

    end # main each
  end
end
