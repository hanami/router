# frozen_string_literal: true

require "hanami/router/node"
require "hanami/router/leaf"

RSpec.describe Hanami::Router::Node do
  describe "#initialize" do
    it "returns a #{described_class} instance" do
      expect(subject).to be_kind_of(described_class)
    end
  end

  describe "#get" do
    context "when segment is found" do
      context "and segment is fixed" do
        it "returns a node" do
          segment = "foo"
          param_keys = []
          param_values = []

          subject.put(segment, param_keys)

          expect(subject.get(segment, param_values)).to be_kind_of(described_class)
        end
      end

      context "and segment is variable" do
        it "returns a node" do
          dynamic_segment = ":foo"
          param_keys = []
          param_values = []

          subject.put(dynamic_segment, param_keys)

          expect(subject.get("bar", param_values)).to be_kind_of(described_class)
        end
      end
    end

    context "when segment is not found" do
      it "returns nil" do
        segment = "foo"
        param_keys = []
        param_values = []

        subject.put(segment, param_keys)

        expect(subject.get("bar", param_values)).to be_nil
      end
    end
  end

  describe "#match" do
    context "when segment is fixed" do
      context "and match not found" do
        it "returns nil" do
          segment = "foo"
          route = "/foo"
          to = double("to")
          constraints = {}
          path = "/bar"
          param_keys = []
          param_values = []

          subject.put(segment, param_keys).leaf!(param_keys, to, constraints)

          expect(subject.get(segment, param_values).match(param_values)).to be_nil
        end
      end

      context "and match is found" do
        it "returns a Leaf object" do
          segment = "foo"
          route = "/foo"
          to = double("to")
          constraints = {}
          param_keys = []
          param_values = []

          subject.put(segment, param_keys).leaf!(param_keys, to, constraints)

          expect(subject.get(segment, param_values).match(param_values)).to be_kind_of(Hanami::Router::Leaf)
        end
      end
    end

    context "when segment is variable" do
      context "and match not found" do
        it "returns nil" do
          segment = ":foo"
          route = "/:foo"
          to = double("to")
          constraints = {foo: :digit}
          path = "/bar"
          param_keys = []
          param_values = []

          subject.put(segment, param_keys).leaf!(param_keys, to, constraints)

          expect(subject.get(segment, param_values).match(param_values)).to be_nil
        end
      end

      context "and match found" do
        it "returns Leaf object" do
          segment = ":foo"
          route = "/:foo"
          to = double("to")
          constraints = {foo: :digit}
          path = "/123"
          param_keys = []
          param_values = []

          subject.put(segment, param_keys).leaf!(param_keys, to, constraints)

          expect(subject.get(segment, param_values).match(param_values)).to be_kind_of(Hanami::Router::Leaf)
        end
      end
    end
  end
end
