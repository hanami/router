# frozen_string_literal: true

RSpec.describe Hanami::Routing do
  describe ".http_verbs" do
    it "returns a set of mountable HTTP verbs" do
      expect(described_class.http_verbs).to eq(RSpec::Support::HTTP.mountable_verbs)
    end
  end
end
