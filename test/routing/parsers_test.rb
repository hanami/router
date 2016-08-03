require 'test_helper'
require 'rack/mock'

describe Hanami::Routing::Parsers do
  describe '#initialize' do
    it 'raises error when unknown parser is given' do
      begin
        Hanami::Routing::Parsers.new(:a_parser)
      rescue Hanami::Routing::Parsing::UnknownParserError => e
        e.message.must_equal "Unknown Parser: `a_parser'"
      end
    end
  end

  describe '#call' do
    before do
      @parsers = Hanami::Routing::Parsers.new(parsers)
    end

    let(:env)  { Rack::MockRequest.env_for('/', method: 'POST', 'CONTENT_TYPE' => content_type, input: body) }
    let(:body)         { '' }
    let(:content_type) { '' }

    describe 'with nil parsers' do
      let(:parsers) { nil }

      it "returns the env as it is" do
        @parsers.call(env).must_equal(env)
      end
    end

    describe 'with empty parsers' do
      let(:parsers) { [] }

      it "returns the env as it is" do
        @parsers.call(env).must_equal(env)
      end
    end

    describe 'with JSON parser' do
      let(:parsers) { [:json] }

      describe 'and a JSON request' do
        let(:body)         { %({"attribute":"ok"}) }
        let(:content_type) { 'application/json' }

        it "parses params from body" do
          result = @parsers.call(env)
          result['router.params'].must_equal({"attribute" => "ok"})
        end

        it "stores parsed body" do
          result = @parsers.call(env)
          result['router.parsed_body'].must_equal({"attribute" => "ok"})
        end

        describe "with non hash body" do
          let(:body) { %(["foo"]) }

          it "parses params from body" do
            result = @parsers.call(env)
            result['router.params'].must_equal({"_" => ["foo"]})
          end

          it "stores parsed body" do
            result = @parsers.call(env)
            result['router.parsed_body'].must_equal({"_" => ["foo"]})
          end
        end

        describe 'with malformed json' do
          let(:body) { %({"hanami":"ok" "attribute":"ok"}) }
          it 'raises an exception' do
            -> { @parsers.call(env) }.must_raise(Hanami::Routing::Parsing::BodyParsingError)
          end
        end
      end

      describe 'and a JSON API request' do
        let(:body)         { %({"attribute":"ok"}) }
        let(:content_type) { 'application/vnd.api+json' }

        it "parses params from body" do
          result = @parsers.call(env)
          result['router.params'].must_equal({"attribute" => "ok"})
        end

        it "stores parsed body" do
          result = @parsers.call(env)
          result['router.parsed_body'].must_equal({"attribute" => "ok"})
        end

        describe 'with malformed json' do
          let(:body) {  %({"hanami":"ok" "attribute":"ok"}) }
          it 'raises an exception' do
            -> { @parsers.call(env) }.must_raise(Hanami::Routing::Parsing::BodyParsingError)
          end
        end
      end

      describe 'and a non-JSON request' do
        let(:body)         { %(<element>ok</element>) }
        let(:content_type) { 'application/xml' }

        it "returns the env as it is" do
          @parsers.call(env).must_equal(env)
        end
      end
    end
  end
end
