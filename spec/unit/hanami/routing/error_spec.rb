# frozen_string_literal: true

RSpec.describe Hanami::Routing::Error do
  it "inherits from ::StandardError" do
    expect(Hanami::Routing::Error.superclass).to eq(StandardError)
  end

  it "is parent to all custom exception" do
    expect(Hanami::Routing::InvalidRouteException.superclass).to eq(Hanami::Routing::Error)
    expect(Hanami::Routing::EndpointNotFound.superclass).to eq(Hanami::Routing::Error)
  end
end
