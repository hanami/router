# frozen_string_literal: true

require "hanami/middleware/node"

RSpec.describe Hanami::Middleware::Node do
  describe "#initialize" do
    it "returns a #{described_class} instance" do
      expect(subject).to be_kind_of(described_class)
    end
  end

  describe "#freeze" do
    it "prevents to add children nodes" do
      subject.freeze
      expect(subject).to be_frozen

      expect { subject.put("foo") }.to raise_error(FrozenError)
    end
  end

  describe "#put" do
    it "adds a segment" do
      segment = "foo"
      subject.put(segment)
    end
  end

  describe "#get" do
    context "when segment is found" do
      context "and segment is defined as symbol" do
        it "returns the node" do
          segment = "foo"
          dynamic_segment = ":bar"
          subject.put(dynamic_segment)

          expect(subject.get(segment)).to be_kind_of(described_class)
        end
      end

      context "and segment is defined as string" do
        it "returns the node" do
          segment = "foo"
          subject.put(segment)

          expect(subject.get(segment)).to be_kind_of(described_class)
        end
      end
    end

    context "when segment is not found" do
      context "and node is leaf" do
        it "returns self" do
          expect(subject.get("foo")).to be(subject)
        end
      end

      context "and node is leaf" do
        it "returns self" do
          segment = "foo"

          expect(subject.get(segment)).to be(subject)
        end
      end

      context "and node is not leaf" do
        it "returns nil" do
          segment = "foo"
          subject.put(segment)

          expect(subject.get("bar")).to be(nil)
        end
      end
    end
  end

  describe "#app!" do
    it "sets the app" do
      subject.app!(double("app"))
    end
  end

  describe "#app?" do
    context "when app is set" do
      it "returns true" do
        subject.app!(double("app"))
        expect(subject.app?).to be(true)
      end
    end

    context "when app is not set" do
      it "returns false" do
        expect(subject.app?).to be(false)
      end
    end
  end
end
