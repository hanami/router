# frozen_string_literal: true

require "hanami/middleware/body_parser"
require "rack/mock"

RSpec.describe Hanami::Middleware::BodyParser do
  let(:app) { ->(_env) { [200, {}, "app"] } }

  describe "#add_parser" do
    context "unknown parser" do
      it "raises error" do
        begin
          Hanami::Middleware::BodyParser.new(app, :a_parser)
        rescue Hanami::Middleware::BodyParser::UnknownParserError => e
          expect(e.message).to eq("Unknown Parser: `a_parser'")
        end
      end
    end

    context "when parser is a class" do
      it "allows to pass parser that inherit from Middleware::Parser" do
        expect do
          Hanami::Middleware::BodyParser.new(app, XmlMiddelwareParser)
        end.to_not raise_error
      end

      it "raises error if parser do not inherit from Middleware::Parser" do
        parser = CsvMiddelwareParser = Class.new
        expect do
          Hanami::Middleware::BodyParser.new(app, parser)
        end.to raise_error(Hanami::Middleware::BodyParser::UnknownParserError)
      end
    end
  end
end
