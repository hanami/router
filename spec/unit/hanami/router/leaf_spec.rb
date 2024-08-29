# frozen_string_literal: true

require "hanami/router/leaf"

RSpec.describe Hanami::Router::Leaf do
  let(:subject)     { described_class.new(route, to, constraints) }
  let(:route)       { "/test/route" }
  let(:to)          { "test proc" }
  let(:constraints) { {} }

  describe "#initialize" do
    it "returns a #{described_class} instance" do
      expect(subject).to be_kind_of(described_class)
    end
  end
  
  describe "#to" do
    it "returns the endpoint passed as 'to' when initialized" do
      expect(subject.to).to eq(to)
    end
  end
  
  describe "#match" do
    context "when path matches route" do
      let(:matching_path)    { route }

      it "returns true" do
        expect(subject.match(matching_path)).to be_truthy
      end
    end

    context "when path doesn't match route" do
      let(:non_matching_path) { "/bad/path" }

      it "returns true" do
        expect(subject.match(non_matching_path)).to be_falsey
      end
    end
  end

  describe "#params" do
    context "without previously calling #match(path)" do
      it "returns nil" do
        params = subject.params

        expect(params).to be_nil
      end
    end

    context "with variable path" do
      let(:route)           { "test/:route" }
      let(:matching_path)   { "test/path" }
      let(:matching_params) { {"route" => "path"} }

      it "returns captured params" do
        subject.match(matching_path)
        params = subject.params

        expect(params).to eq(matching_params)
      end
    end
  end
end
