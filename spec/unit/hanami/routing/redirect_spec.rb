RSpec.describe Hanami::Routing::Redirect do
  describe "#initialize" do
    it "instantiate a frozen object" do
      redirect = described_class.new("/", 301)

      expect(redirect).to be_kind_of(described_class)
      expect(redirect).to be_frozen
    end

    it "raises error if path is nil" do
      expect { described_class.new(nil, 301) }.to raise_error(ArgumentError, "Path is nil")
    end

    it "raises error if status code is nil" do
      expect { described_class.new("/", nil) }.to raise_error(ArgumentError, "Status code isn't a redirect: nil")
    end

    it "raises error if status code isn't a redirect" do
      expect { described_class.new("/", 200) }.to raise_error(ArgumentError, "Status code isn't a redirect: 200")
    end
  end

  describe "#call" do
    it "returns a serialized Rack response" do
      redirect = described_class.new("/destination", 301)
      status, headers, body = *redirect.call({})

      expect(status).to  be(301)
      expect(headers).to eq("Location" => "/destination")
      expect(body).to    eq([])
    end
  end
end
