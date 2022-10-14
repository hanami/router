# frozen_string_literal: true

require "hanami/middleware/body_parser"
require "rack/mock"

RSpec.describe Hanami::Middleware::BodyParser do
  let(:app) { ->(_env) { [200, {}, "app"] } }

  describe ".new" do
    it "accepts a parser name" do
      body_parser = Hanami::Middleware::BodyParser.new(app, :json)

      expect(body_parser.instance_variable_get("@parsers")["application/json"])
        .to be_instance_of(Hanami::Middleware::BodyParser::JsonParser)
    end

    it "accepts a parser name with additional mime-type(s)" do
      body_parser = Hanami::Middleware::BodyParser.new(app, [json: "application/json+scim"])

      expect(body_parser.instance_variable_get("@parsers")["application/json+scim"])
        .to be_instance_of(Hanami::Middleware::BodyParser::JsonParser)
    end

    it "raises error when parser spec is invalid" do
      Hanami::Middleware::BodyParser.new(app, :a_parser)
    rescue Hanami::Middleware::BodyParser::UnknownParserError => exception
      expect(exception.message).to eq("Unknown body parser: `:a_parser'")
    end
  end
end
