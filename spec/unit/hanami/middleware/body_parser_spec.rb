require 'hanami/middleware/body_parser'
require 'hanami/middleware/body_parser/json_parser'

RSpec.describe Hanami::Middleware::BodyParser do
  describe '.for' do
    let(:parser_class) {
      Class.new do
        def mime_types
          ['text']
        end

        def parse(body)
          body
        end
      end
    }

    it 'requires and initializes a parser by name' do
      expect(described_class.for(:json)).to be_a(Hanami::Middleware::BodyParser::JsonParser)
      expect(described_class.for("json")).to be_a(Hanami::Middleware::BodyParser::JsonParser)
    end

    it 'initializes a parser from a class' do
      expect(described_class.for(parser_class)).to be_a(parser_class)
    end

    it 'passes through a parser instance' do
      parser = parser_class.new
      expect(described_class.for(parser)).to eql parser
    end

    it 'raises an exception if the parser does not conform to requirements' do
      parser = Object.new
      expect { described_class.for(parser) }.to raise_exception(Hanami::Middleware::BodyParser::UnknownParserError)
    end
  end
end
