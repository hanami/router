# frozen_string_literal: true

require "hanami/middleware/body_parser"
require "rack/mock"

RSpec.describe Hanami::Middleware::BodyParser do
  let(:app) { ->(_env) { [200, {}, "app"] } }

  context "unknown parser" do
    it "raises error" do
      Hanami::Middleware::BodyParser.new(app, :a_parser)
    rescue Hanami::Middleware::BodyParser::UnknownParserError => exception
      expect(exception.message).to eq("Unknown body parser: `:a_parser'")
    end
  end
end
