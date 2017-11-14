# frozen_string_literal: true

RSpec.describe Hanami::Routing::Uri do
  describe ".build" do
    context "http" do
      it "builds an URI string with the given arguments" do
        actual = described_class.build(scheme: "http", host: "localhost", port: 80)

        expect(actual).to be_kind_of(String)
        expect(actual).to eq("http://localhost")
      end

      it "has explicit port when the given value isn't the standard for http (80)" do
        actual = described_class.build(scheme: "http", host: "localhost", port: 8080)

        expect(actual).to be_kind_of(String)
        expect(actual).to eq("http://localhost:8080")
      end
    end

    context "https" do
      it "builds an URI string with the given arguments" do
        actual = described_class.build(scheme: "https", host: "localhost", port: 443)

        expect(actual).to be_kind_of(String)
        expect(actual).to eq("https://localhost")
      end

      it "has explicit port when the given value isn't the standard for https (443)" do
        actual = described_class.build(scheme: "https", host: "localhost", port: 4433)

        expect(actual).to be_kind_of(String)
        expect(actual).to eq("https://localhost:4433")
      end
    end

    it "raises error when scheme isn't specified" do
      expect { described_class.build(host: "localhost", port: 80) }.to raise_error(ArgumentError)
    end

    it "raises error when host isn't specified" do
      expect { described_class.build(scheme: "http", port: 80) }.to raise_error(ArgumentError)
    end

    it "raises error when port isn't specified" do
      expect { described_class.build(scheme: "http", host: "localhost") }.to raise_error(ArgumentError)
    end

    it "raises error when scheme is nil" do
      expect { described_class.build(scheme: nil, host: "localhost", port: 80) }.to raise_error(ArgumentError, %(Unknown scheme: nil))
    end

    it "raises error when scheme is unknown" do
      expect { described_class.build(scheme: "foo", host: "localhost", port: 80) }.to raise_error(ArgumentError, %(Unknown scheme: "foo"))
    end

    it "raises error when host is nil" do
      expect { described_class.build(scheme: "http", host: nil, port: 80) }.to raise_error(ArgumentError, %(host is nil))
    end

    it "raises error when port is nil" do
      expect { described_class.build(scheme: "http", host: "localhost", port: nil) }.to raise_error(ArgumentError, %(port is nil))
    end
  end
end
