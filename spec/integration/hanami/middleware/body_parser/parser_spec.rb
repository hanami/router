require 'hanami/middleware/body_parser'
require 'rack/mock'

RSpec.describe Hanami::Middleware::BodyParser::Parser do
  describe 'JSON parser'do
    let(:app) { -> (env) { [200, {}, "app"] } }
    let(:middleware) { Hanami::Middleware::BodyParser.new(app, [:json]) }
    let(:env) { Rack::MockRequest.env_for('/', method: 'POST', 'CONTENT_TYPE' => content_type, input: body) }
    let(:body)         { '' }
    let(:content_type) { '' }

    describe 'and a JSON request' do
      let(:body)         { %({"attribute":"ok"}) }
      let(:content_type) { 'application/json' }

      it "parses params from body" do
        middleware.call(env)
        expect(env['router.params']).to eq(attribute: "ok")
      end

      it "stores parsed body" do
        middleware.call(env)
        expect(env['router.parsed_body']).to eq('attribute' => "ok")
      end

      describe "with non hash body" do
        let(:body) { %(["foo"]) }

        it "parses params from body" do
          middleware.call(env)
          expect(env['router.params']).to eq("_" => ["foo"])
        end

        it "stores parsed body" do
           middleware.call(env)
          expect(env['router.parsed_body']).to eq(["foo"])
        end
      end

      describe 'with malformed json' do
        let(:body) { %({"hanami":"ok" "attribute":"ok"}) }
        it 'raises an exception' do
          expect { middleware.call(env) }.to raise_error(Hanami::Middleware::BodyParser::BodyParsingError)
        end
      end
    end

    describe 'and a JSON API request' do
      let(:body)         { %({"data": {"attribute":"ok"}}) }
      let(:content_type) { 'application/vnd.api+json' }

      it "parses params from body" do
        middleware.call(env)
        expect(env['router.params']).to eq(data: { attribute: "ok" })
      end

      it "stores parsed body" do
        middleware.call(env)
        expect(env['router.parsed_body']).to eq('data' => { 'attribute' => "ok" })
      end

      describe 'with malformed json' do
        let(:body) {  %({"hanami":"ok" "attribute":"ok"}) }

        it 'raises an exception' do
          expect { middleware.call(env) }.to raise_error(Hanami::Middleware::BodyParser::BodyParsingError)
        end
      end
    end

    describe 'and a non-JSON request' do
      let(:body)         { %(<element>ok</element>) }
      let(:content_type) { 'application/xml' }

      it "returns the app as it is" do
        expect(middleware.call(env)).to eq(app.(env))
      end
    end
  end
end
