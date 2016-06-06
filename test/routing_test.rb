require 'test_helper'

describe Hanami::Router do
  before do
    @router = Hanami::Router.new
    @app    = Rack::MockRequest.new(@router)
  end

  after do
    @router.reset!
  end

  [ 'get', 'post', 'delete', 'put', 'patch', 'trace', 'options' ].each do |verb|

    describe "##{ verb }" do
      describe 'path recognition' do
        it 'recognize fixed string' do
          response = [200, {}, ['Fixed!']]
          @router.send(verb, '/hanami', to: ->(env) { response })

          response.must_be_same_as @app.request(verb.upcase, '/hanami', lint: true)
        end

        it 'recognize moving parts string' do
          response = [200, {}, ['Moving!']]
          @router.send(verb, '/hanami/:id', to: ->(env) { response })

          response.must_be_same_as @app.request(verb.upcase, '/hanami/23', lint: true)
        end

        it 'recognize globbing string' do
          response = [200, {}, ['Globbing!']]
          @router.send(verb, '/hanami/*', to: ->(env) { response })

          response.must_be_same_as @app.request(verb.upcase, '/hanami/all', lint: true)
        end

        it 'recognize format string' do
          response = [200, {}, ['Format!']]
          @router.send(verb, '/hanami/:id(.:format)', to: ->(env) { response })

          response.must_be_same_as @app.request(verb.upcase, '/hanami/all.json', lint: true)
        end

        it 'accepts a block' do
          response = [200, {}, ['Block!']]
          @router.send(verb, '/block') {|e| response }

          response.must_be_same_as @app.request(verb.upcase, '/block', lint: true)
        end
      end

      describe 'named routes' do
        it 'recognizes by the given symbol' do
          response = [200, {}, ['Named route!']]

          @router.send(verb, '/named_route', to: ->(env) { response }, as: :"#{ verb }_named_route")

          @router.path(:"#{ verb }_named_route").must_equal '/named_route'
          @router.url(:"#{ verb }_named_route").must_equal  'http://localhost/named_route'
        end

        it 'compiles variables' do
          response = [200, {}, ['Named %route!']]

          @router.send(verb, '/named_:var', to: ->(env) { response }, as: :"#{ verb }_named_route_var")

          @router.path(:"#{ verb }_named_route_var", var: 'route').must_equal '/named_route'
          @router.url(:"#{ verb }_named_route_var", var: 'route').must_equal  'http://localhost/named_route'
        end

        it 'allows custom url parts' do
          response = [200, {}, ['Named route with custom parts!']]

          router = Hanami::Router.new(scheme: 'https', host: 'hanamirb.org', port: 443)
          router.send(verb, '/custom_named_route', to: ->(env) { response }, as: :"#{ verb }_custom_named_route")

          router.url(:"#{ verb }_custom_named_route").must_equal 'https://hanamirb.org/custom_named_route'
        end
      end

      describe 'constraints' do
        it 'recognize when called with matching constraints' do
          response = [200, {}, ['Moving with constraints!']]

          @router.send(verb, '/hanami/:id', to: ->(env) { response }, id: /\d+/)
          response.must_be_same_as @app.request(verb.upcase, '/hanami/23', lint: true)

          @app.request(verb.upcase, '/hanami/flower', lint: true).status.must_equal 404
        end
      end
    end

  end # main each

  describe 'root' do
    describe 'path recognition' do
      it 'recognize fixed string' do
        response = [200, {}, ['Fixed!']]
        @router.root(to: ->(env) { response })

        response.must_be_same_as @app.request('GET', '/', lint: true)
      end

      it 'accepts a block' do
        response = [200, {}, ['Block!']]
        @router.root {|e| response }

        response.must_be_same_as @app.request('GET', '/', lint: true)
      end

      it 'handles not found on GET when only POST root is defined' do
        @router.post("/", to: ->(_env) { [201, {}, [""]] })

        status, _, _ = @app.request('GET', '/bogus', lint: true)
        status.must_equal(404)
      end
    end

    describe 'named route for root' do
      it 'recognizes by the given symbol' do
        response = [200, {}, ['Named route!']]

        @router.root(to: ->(env) { response })

        @router.path(:root).must_equal '/'
        @router.url(:root).must_equal  'http://localhost/'
      end
    end
  end
end
