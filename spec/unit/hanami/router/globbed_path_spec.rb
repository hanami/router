# frozen_string_literal: true

RSpec.describe Hanami::Router::GlobbedPath do
  let(:http_method) { "PUT" }
  let(:path) { Mustermann.new("/api/*any", type: :rails, version: "5.0") }
  let(:to) { double(:endpoint) }

  subject { described_class.new(http_method, path, to) }

  describe "#endpoint_and_params" do
    let(:env) { {} }

    it "returns an empty array if the method doesn't match" do
      env.merge!(
        Rack::PATH_INFO => "/api/orders",
        Rack::REQUEST_METHOD => "GET"
      )

      expect(subject.endpoint_and_params(env)).to eq([])
    end

    it "returns an empty array if the pattern doesn't match" do
      env.merge!(
        Rack::PATH_INFO => "/orders",
        Rack::REQUEST_METHOD => "PUT"
      )

      expect(subject.endpoint_and_params(env)).to eq([])
    end

    it "returns the endpoint and captures if both method and pattern match" do
      env.merge!(
        Rack::PATH_INFO => "/api/orders",
        Rack::REQUEST_METHOD => "PUT"
      )

      expect(subject.endpoint_and_params(env)).to eq([to, {"any" => "orders"}])
    end
  end
end
