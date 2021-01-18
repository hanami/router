# frozen_string_literal: true

require "hanami/router/inspector"

RSpec.describe Hanami::Router::Inspector do
  subject { described_class.new }

  describe "#initialize" do
    it "returns a frozen instance of #{described_class}" do
      expect(subject).to be_kind_of(described_class)
      expect(subject).to be_frozen
    end
  end

  describe "#call" do
    context "no routes" do
      let(:routes) { [] }

      it "returns an empty result" do
        expect(subject.call(routes)).to eq("")
      end
    end

    context "with routes" do
      let(:routes) do
        [{http_method: "GET", path: "/", to: "home#index", as: :root, constraints: {}, blk: nil}]
      end

      it "returns inspected routes" do
        expected = [
          "GET     /                             home#index                    as :root"
        ]

        actual = subject.call(routes)
        expected.each do |route|
          expect(actual).to include(route)
        end
      end
    end
  end
end
