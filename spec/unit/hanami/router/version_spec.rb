# frozen_string_literal: true

RSpec.describe "Hanami::Router::VERSION" do
  it "exposes version" do
    expect(Hanami::Router::VERSION).to eq("2.1.0.rc3")
  end
end
