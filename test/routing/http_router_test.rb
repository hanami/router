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

  describe '#rewrite_partial_path_info' do
    before do
      @request_env = nil
      @router = Hanami::Routing::HttpRouter.new
      @router.add("/sidekiq*").to { |env| @request_env = env; [200, {}, []] }
    end

    describe 'when from partial match' do
      it 'sets PATH_INFO correctly' do
        @router.call(Rack::MockRequest.env_for("/sidekiq/queues"))
        @request_env['PATH_INFO'].to_s.must_equal '/queues'
      end

      it 'sets SCRIPT_NAME correctly' do
        @router.call(Rack::MockRequest.env_for("/sidekiq/queues"))
        @request_env['SCRIPT_NAME'].to_s.must_equal '/sidekiq'
      end
    end

    describe 'when from partial match of single' do
      it 'sets PATH_INFO correctly' do
        @router.call(Rack::MockRequest.env_for("/sidekiq"))
        @request_env['PATH_INFO'].to_s.must_equal '/'
      end

      it 'sets SCRIPT_NAME correctly' do
        @router.call(Rack::MockRequest.env_for("/sidekiq"))
        @request_env['SCRIPT_NAME'].to_s.must_equal '/sidekiq'
      end
    end

    describe 'when from encoded path' do
      it 'sets PATH_INFO correctly' do
        @router.call(Rack::MockRequest.env_for("/sidekiq/queues/some%20path"))
        @request_env['PATH_INFO'].to_s.must_equal '/queues/some%20path'
      end

      it 'sets SCRIPT_NAME correctly' do
        @router.call(Rack::MockRequest.env_for("/sidekiq/queues/some%20path"))
        @request_env['SCRIPT_NAME'].to_s.must_equal '/sidekiq'
      end
    end
  end
end
