require 'test_helper'
require 'hanami/routing/http_router'

describe Hanami::Routing::HttpRouter do
  class TestRackRequest
    def path_info
      '/post'
    end
  end

  class TestRequest
    def rack_request
      TestRackRequest.new
    end
  end

  describe '#rewrite_path_info' do
    let(:env) { { 'SCRIPT_NAME' => '' } }
    let(:request) { TestRequest.new }

    it 'rejects entries that are matching separator' do
      http_route = Hanami::Routing::HttpRouter.new(prefix: '/')
      http_route.rewrite_path_info(env, request)
      env['SCRIPT_NAME'].to_s.must_equal '/post'
    end
  end
end
