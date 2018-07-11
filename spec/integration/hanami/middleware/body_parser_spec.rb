require 'hanami/middleware/body_parser'
require 'rack/mock'

RSpec.describe Hanami::Middleware::BodyParser do
  describe '#add_parser' do
    context 'unknown parser' do
      it 'raises error' do
        begin
          Hanami::Middleware::BodyParser.new(:a_parser)
        rescue Hanami::Routing::Parsing::UnknownParserError => e
          expect(e.message).to eq("Unknown Parser: `a_parser'")
        end
      end
    end

    context 'when parser is a class' do
      it 'allows to pass parser that inherit from Middleware::Parser' do
        expect {
          Hanami::Middleware::BodyParser.new(XmlMiddelwareParser)
        }.to_not raise_error
      end

      it 'raises error if parser do not inherit from Middleware::Parser' do
        parser = CsvMiddelwareParser = Class.new
        expect {
          Hanami::Middleware::BodyParser.new(parser)
        }.to raise_error(Hanami::Routing::Parsing::UnknownParserError)
      end
    end
  end
end
