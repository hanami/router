# frozen_string_literal: true

require "hanami/middleware/trie"

RSpec.describe Hanami::Middleware::Trie do
  subject { described_class.new(app) }
  let(:app) { -> (*) { [200, {"content-length" => "2"}, ["OK"]] } }

  describe "#initialize" do
    it "returns an instance of #{described_class}" do
      expect(subject).to be_kind_of(described_class)
    end
  end

  describe "#add" do
    it "adds node" do
      subject.add("/foo", double("foo"))
    end
    it "adds multiple fixed segments" do
      subject.add("/foo/bar/baz", double("foo"))
    end
    it "adds a fixed segment followed by a variable segment" do
      subject.add("/foo/:bar", double("foo"))
    end
    it "adds a variable segment followed by a fixed segment" do
      subject.add("/:foo/bar", double("foo"))
    end
    it "adds a variable segment, and then a variable segment followed by a fixed segment with different variable slugs" do
      subject.add("/:foo", double("foo"))
      subject.add("/:bar/foo", double("bar"))
    end
    it "adds a variable segment followed by a fixed segment, and then a variable segment with different variable slugs" do
      subject.add("/:bar/foo", double("bar"))
      subject.add("/:foo", double("foo"))
    end
  end

  describe "#find" do
    before do
      subject.add("/admin", admin)
      subject.add("/api", api)
      subject.add("/api/v1", api_v1)
      subject.add("/var/:foo", foo)
      subject.add("/var/:bar/foo", bar)
    end
    let(:admin) { double("admin") }
    let(:api) { double("api") }
    let(:api_v1) { double("api_v1") }
    let(:foo) { double("foo") }
    let(:bar) { double("bar") }

    it "finds nodes by given path" do
      expect(subject.find("/")).to eq(app)
      expect(subject.find("/admin")).to eq(admin)
      expect(subject.find("/admin/")).to eq(admin) # trailing slash
      expect(subject.find("/api")).to eq(api)
      expect(subject.find("/api/v1")).to eq(api_v1)
    end

    it "matches path prefix" do
      expect(subject.find("/admin/users")).to eq(admin)
      expect(subject.find("/api/v1/songs")).to eq(api_v1)
      expect(subject.find("/api/v1/songs/")).to eq(api_v1) # trailing slash
    end

    it "matches path with a variable segment" do
      expect(subject.find("/var/foo")).to eq(foo)
    end

    it "matches path with a variable segment followed by a fixed segment" do
      expect(subject.find("/var/bar/foo")).to eq(bar)
    end

    it "falls back to app, if no node is associated with given path" do
      expect(subject.find("/foo")).to eq(app)
    end
  end

  describe "#empty?" do
    context "without nodes" do
      it "returns true" do
        expect(subject).to be_empty
      end
    end

    context "with nodes" do
      it "returns false" do
        subject.add("/bar", double("bar"))
        expect(subject).to_not be_empty
      end
    end
  end
end
