require 'hanami/middleware/body_parser'
require 'rack/mock'

RSpec.describe Hanami::Middleware::BodyParser do
  let(:app) { -> (env) { [200, {}, "app"] } }

  context 'unknown parser' do
    it 'raises error' do
      begin
        Hanami::Middleware::BodyParser.new(app, :a_parser)
      rescue Hanami::Middleware::BodyParser::UnknownParserError => e
        expect(e.message).to eq("Unknown Parser: `a_parser'")
      end
    end

    # This spec will have to be remove once we remove the Hanami::Routing::Parsing module
    it 'rescues old error from parsing module' do
      begin
        Hanami::Middleware::BodyParser.new(app, :a_parser)
      rescue Hanami::Routing::Parsing::UnknownParserError => e
        expect(e.message).to eq("Unknown Parser: `a_parser'")
      end
    end
  end
end
