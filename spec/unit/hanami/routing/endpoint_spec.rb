# frozen_string_literal: true

RSpec.describe Hanami::Routing::Endpoint do
  describe ".find" do
    context "string" do
      it "finds object from its class name" do
        expect(described_class.find("MyMiddleware", nil)).to be_kind_of(MyMiddleware)
      end

      it "finds object from its namespaced class name" do
        expect(described_class.find("Middleware::Runtime", nil)).to be_kind_of(Middleware::Runtime)
      end

      it "finds object from its class name and namespace" do
        expect(described_class.find("Runtime", Middleware)).to be_kind_of(Middleware::Runtime)
      end

      it "finds Hanami action" do
        expect(described_class.find("home#index", Web::Controllers)).to be_kind_of(Web::Controllers::Home::Index)
      end

      it "returns a lazy endpoint when the class cannot be found" do
        expect(described_class.find("Unknown", nil)).to be_kind_of(Hanami::Routing::LazyEndpoint)
      end
    end

    context "class" do
      it "returns the given class if it respond to .call" do
        expect(described_class.find(Middleware::ClassMiddleware, nil)).to be(Middleware::ClassMiddleware)
      end

      it "returns an instance of the given class if it respond to #call" do
        expect(described_class.find(Middleware::InstanceMiddleware, nil)).to be_kind_of(Middleware::InstanceMiddleware)
      end
    end

    context "proc" do
      it "returns the given proc" do
        endpoint = ->() {}
        expect(described_class.find(endpoint, nil)).to be(endpoint)
      end
    end

    context "object" do
      it "returns the given object" do
        endpoint = Object.new
        def endpoint.call; end
        expect(described_class.find(endpoint, nil)).to be(endpoint)
      end
    end

    it "raises error if the found object isn't compatible with Rack" do
      endpoint = Object.new
      expect { described_class.find(endpoint, nil) }.to raise_error(Hanami::Routing::NotCallableEndpointError, "#{endpoint.inspect} isn't compatible with Rack. Please make sure it implements #call.")
    end
  end
end
