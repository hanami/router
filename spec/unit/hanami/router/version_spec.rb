# frozen_string_literal: true

RSpec.describe "Hanami::Router::VERSION" do
  it "exposes version" do
    expect(Hanami::Router::VERSION).to eq("2.0.0.beta4")
  end
end
