require 'hanami/middleware/body_parser'
require 'hanami/middleware/body_parser/json_parser'

RSpec.describe Hanami::Middleware::BodyParser do
  describe '.for' do
    it 'requires and initializes a parser by name' do
      expect(described_class.for(:json)).to be_a(Hanami::Middleware::BodyParser::JsonParser)
      expect(described_class.for("json")).to be_a(Hanami::Middleware::BodyParser::JsonParser)
    end

    it 'initializes a parser from a class' do
      expect(described_class.for(Hanami::Middleware::BodyParser::JsonParser)).to be_a(Hanami::Middleware::BodyParser::JsonParser)
    end

    it 'passes through a parser instance' do
      parser = Class.new(Hanami::Middleware::BodyParser::Parser).new
      expect(described_class.for(parser)).to eql parser
    end
  end
end
