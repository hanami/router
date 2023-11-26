# frozen_string_literal: true

require "hanami/middleware/app"
require "rack/mock"

RSpec.describe Hanami::Middleware::App do
  subject { described_class.new(app, mapping) }

  let(:app) { Hanami::Router.new { root { "OK" } } }
  let(:mapping) { {"/" => [], "/admin" => [[authentication, [], {}, nil]]} }
  let(:authentication) do
    Class.new do
      def self.inspect
        "<Middleware::Auth>"
      end

      def initialize(app)
        @app = app
      end

      def call(env)
        env["AUTH_USER_ID"] = user_id = "23"
        status, headers, body = @app.call(env)
        headers["X-Auth-User-ID"] = user_id

        [status, headers, body]
      end
    end
  end

  describe "#initialize" do
    it "returns a #{described_class} instance" do
      expect(subject).to be_kind_of(described_class)
    end
  end

  describe "#call" do
    it "bypasses middleware when not used by given path" do
      env = Rack::MockRequest.env_for("/")
      _, headers, _ = subject.call(env)

      expect(headers).to_not have_key("X-Auth-User-ID")
    end

    it "invokes middleware when used by given path" do
      env = Rack::MockRequest.env_for("/admin")
      _, headers, _ = subject.call(env)

      expect(headers).to have_key("X-Auth-User-ID")
    end
  end

  describe "#to_inspect" do
    context "when app isn't configured for inspection" do
      it "returns empty string" do
        expect(subject.to_inspect).to eq("")
      end
    end

    context "when app is configured for inspection" do
      let(:app) { Hanami::Router.new(inspector: inspector) }
      let(:inspector) { -> { "routes!" } }

      it "returns empty string" do
        expect(subject.to_inspect).to eq("routes!")
      end
    end
  end
end
