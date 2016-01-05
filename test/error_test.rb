require 'test_helper'

describe Lotus::Routing::Error do
  it 'inherits from ::StandardError' do
    Lotus::Routing::Error.superclass.must_equal StandardError
  end

  it 'is parent to all custom exception' do
    Lotus::Routing::Parsing::BodyParsingError.superclass.must_equal Lotus::Routing::Error
    Lotus::Routing::Parsing::UnknownParserError.superclass.must_equal Lotus::Routing::Error
    Lotus::Routing::InvalidRouteException.superclass.must_equal Lotus::Routing::Error
    Lotus::Routing::EndpointNotFound.superclass.must_equal Lotus::Routing::Error
  end
end
