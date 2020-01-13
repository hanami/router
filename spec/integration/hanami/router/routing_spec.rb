RSpec.describe Hanami::Router do
  before do
    @router = Hanami::Router.new
    @app    = Rack::MockRequest.new(@router)
  end

  after do
    @router.reset!
  end

  %w[get post delete put patch trace options].each do |verb|
    describe "##{verb}" do
      describe 'path recognition' do
        it 'recognize fixed string' do
          response = [200, {"Content-Length" => "6"}, ['Fixed!']]
          @router.send(verb, '/hanami', to: ->(_env) { response })

          expect(@app.request(verb.upcase, '/hanami', lint: true).to_a).to eq(response)
        end

        it 'recognize moving parts string' do
          response = [200, {"Content-Length" => "7"}, ['Moving!']]
          @router.send(verb, '/hanami/:id', to: ->(_env) { response })

          expect(@app.request(verb.upcase, '/hanami/23', lint: true).to_a).to eq(response)
        end

        it 'recognize globbing string' do
          response = [200, {"Content-Length" => "9"}, ['Globbing!']]
          @router.send(verb, '/hanami/*', to: ->(_env) { response })

          expect(@app.request(verb.upcase, '/hanami/all', lint: true).to_a).to eq(response)
        end

        it 'recognize format string' do
          response = [200, {"Content-Length" => "7"}, ['Format!']]
          @router.send(verb, '/hanami/:id(.:format)', to: ->(_env) { response })

          expect(@app.request(verb.upcase, '/hanami/all.json', lint: true).to_a).to eq(response)
        end

        it 'accepts a block' do
          response = [200, {"Content-Length" => "6"}, ['Block!']]
          @router.send(verb, '/block') { |_e| response }

          expect(@app.request(verb.upcase, '/block', lint: true).to_a).to eq(response)
        end
      end

      describe 'named routes' do
        it 'recognizes by the given symbol' do
          response = [200, {}, ['Named route!']]

          @router.send(verb, '/named_route', to: ->(_env) { response }, as: :"#{ verb }_named_route")

          expect(@router.path(:"#{ verb }_named_route")).to eq('/named_route')
          expect(@router.url(:"#{ verb }_named_route")).to eq('http://localhost/named_route')
        end

        it 'compiles variables' do
          response = [200, {}, ['Named %route!']]

          @router.send(verb, '/named_:var', to: ->(_env) { response }, as: :"#{ verb }_named_route_var")

          expect(@router.path(:"#{ verb }_named_route_var", var: 'route')).to eq('/named_route')
          expect(@router.url(:"#{ verb }_named_route_var", var: 'route')).to eq('http://localhost/named_route')
        end

        it 'allows custom url parts' do
          response = [200, {}, ['Named route with custom parts!']]

          router = Hanami::Router.new(scheme: 'https', host: 'hanamirb.org', port: 443)
          router.send(verb, '/custom_named_route', to: ->(_env) { response }, as: :"#{ verb }_custom_named_route")

          expect(router.url(:"#{ verb }_custom_named_route")).to eq('https://hanamirb.org/custom_named_route')
        end
      end

      describe 'constraints' do
        it 'recognize when called with matching constraints' do
          response = [200, {"Content-Length" => "24"}, ['Moving with constraints!']]
          @router.send(verb, '/hanami/:id', to: ->(_env) { response }, id: /\d+/)

          expect(@app.request(verb.upcase, '/hanami/23', lint: true).to_a).to eq(response)

          expect(@app.request(verb.upcase, '/hanami/flower', lint: true).status).to eq(404)
        end
      end
    end
  end # main each

  describe 'root' do
    describe 'path recognition' do
      it 'recognize fixed string' do
        response = [200, {"Content-Length"=>"6"}, ['Fixed!']]
        @router.root(to: ->(_env) { response })

        expect(@app.request('GET', '/', lint: true).to_a.to_a).to eq(response)
      end

      it 'accepts a block' do
        response = [200, {"Content-Length"=>"6"}, ['Block!']]
        @router.root { |_e| response }

        expect(@app.request('GET', '/', lint: true).to_a.to_a).to eq(response)
      end
    end

    describe 'named route for root' do
      it 'recognizes by the given symbol' do
        response = [200, {}, ['Named route!']]

        @router.root(to: ->(_env) { response })

        expect(@router.path(:root)).to eq('/')
        expect(@router.url(:root)).to eq('http://localhost/')
      end
    end
  end
end
