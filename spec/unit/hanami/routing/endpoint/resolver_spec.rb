# frozen_string_literal: true

RSpec.describe Hanami::Routing::Endpoint::Resolver do
  describe ".call" do
    context "string" do
      it "resolves object from its class name" do
        expect(subject.call("MyMiddleware", nil)).to be_kind_of(MyMiddleware)
      end

      it "resolves object from its namespaced class name" do
        expect(subject.call("Middleware::Runtime", nil)).to be_kind_of(Middleware::Runtime)
      end

      it "resolves object from its class name and namespace" do
        expect(subject.call("Runtime", Middleware)).to be_kind_of(Middleware::Runtime)
      end

      it "resolves Hanami action" do
        expect(subject.call("home#index", Web::Controllers, Action::Configuration.new("web"))).to be_kind_of(Web::Controllers::Home::Index)
      end

      it "returns a lazy endpoint when the class cannot be found" do
        expect(subject.call("Unknown", nil)).to be_kind_of(Hanami::Routing::LazyEndpoint)
      end
    end

    context "class" do
      it "returns the given class if it respond to .call" do
        expect(subject.call(Middleware::ClassMiddleware, nil)).to be(Middleware::ClassMiddleware)
      end

      it "returns an instance of the given class if it respond to #call" do
        expect(subject.call(Middleware::InstanceMiddleware, nil)).to be_kind_of(Middleware::InstanceMiddleware)
      end
    end

    context "proc" do
      it "returns the given proc" do
        endpoint = -> {}
        expect(subject.call(endpoint, nil)).to be(endpoint)
      end
    end

    context "object" do
      it "returns the given object" do
        endpoint = Object.new
        def endpoint.call; end
        expect(subject.call(endpoint, nil)).to be(endpoint)
      end
    end

    it "raises error if the found object isn't compatible with Rack" do
      endpoint = Object.new
      expect { subject.call(endpoint, nil) }.to raise_error(Hanami::Routing::NotCallableEndpointError, "#{endpoint.inspect} isn't compatible with Rack. Please make sure it implements #call.")
    end
  end
end
