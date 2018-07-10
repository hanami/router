RSpec.describe Hanami::Routing::Error do
  it 'inherits from ::StandardError' do
    expect(Hanami::Routing::Error.superclass).to eq(StandardError)
  end

  it 'is parent to all custom exception' do
    expect(Hanami::Routing::Parsing::BodyParsingError.superclass).to eq(Hanami::Routing::Error)
    expect(Hanami::Routing::Parsing::UnknownParserError.superclass).to eq(Hanami::Routing::Error)
    expect(Hanami::Routing::Middleware::BodyParsingError.superclass).to eq(Hanami::Routing::Error)
    expect(Hanami::Routing::Middleware::UnknownParserError.superclass).to eq(Hanami::Routing::Error)
    expect(Hanami::Routing::InvalidRouteException.superclass).to eq(Hanami::Routing::Error)
    expect(Hanami::Routing::EndpointNotFound.superclass).to eq(Hanami::Routing::Error)
  end
end
