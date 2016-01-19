require 'test_helper'

describe Hanami::Routing::Error do
  it 'inherits from ::StandardError' do
    Hanami::Routing::Error.superclass.must_equal StandardError
  end

  it 'is parent to all custom exception' do
    Hanami::Routing::Parsing::BodyParsingError.superclass.must_equal Hanami::Routing::Error
    Hanami::Routing::Parsing::UnknownParserError.superclass.must_equal Hanami::Routing::Error
    Hanami::Routing::InvalidRouteException.superclass.must_equal Hanami::Routing::Error
    Hanami::Routing::EndpointNotFound.superclass.must_equal Hanami::Routing::Error
  end
end
