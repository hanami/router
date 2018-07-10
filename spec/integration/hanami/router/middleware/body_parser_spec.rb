require 'hanami/routing/middleware/body_parser'
require 'rack/mock'

RSpec.describe Hanami::Routing::Middleware::BodyParser do
  describe '#add_parser' do
    context 'unknown parser' do
      it 'raises error' do
        begin
          Hanami::Routing::Middleware::BodyParser.new { add_parser :a_parser }
        rescue Hanami::Routing::Middleware::UnknownParserError => e
          expect(e.message).to eq("Unknown Parser: `a_parser'")
        end
      end
    end

    context 'when parser is a class' do
      it 'allows to pass parser that inherit from Middleware::Parser' do
        expect {
          Hanami::Routing::Middleware::BodyParser.new { add_parser XmlMiddelwareParser }
        }.to_not raise_error
      end

      it 'raises error if parser do not inherit from Middleware::Parser' do
        parser = CsvMiddelwareParser = Class.new
        expect {
          Hanami::Routing::Middleware::BodyParser.new { add_parser parser }
        }.to raise_error(Hanami::Routing::Middleware::UnknownParserError)
      end
    end
  end
end
