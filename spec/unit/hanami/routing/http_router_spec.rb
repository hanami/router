require 'hanami/routing/http_router'

RSpec.describe Hanami::Routing::HttpRouter do
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

      expect(env['SCRIPT_NAME']).to eq('/post')
      expect(env['SCRIPT_NAME']).to be_a_kind_of(String)
    end
  end

  describe '#new' do
    it 'shows deprecation warning regarding options[:parsers]' do
      expect {
        Hanami::Routing::HttpRouter.new(parsers: [:json])
      }.to output(/Hanami::Router options\[:parsers\] is deprecated and it will be removed in future versions/).to_stderr
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
        expect(@request_env['PATH_INFO']).to eq('/queues')
        expect(@request_env['PATH_INFO']).to be_a_kind_of(String)
      end

      it 'sets SCRIPT_NAME correctly' do
        @router.call(Rack::MockRequest.env_for("/sidekiq/queues"))
        expect(@request_env['SCRIPT_NAME']).to eq('/sidekiq')
        expect(@request_env['SCRIPT_NAME']).to be_a_kind_of(String)
      end
    end

    describe 'when from partial match of single' do
      it 'sets PATH_INFO correctly' do
        @router.call(Rack::MockRequest.env_for("/sidekiq"))
        expect(@request_env['PATH_INFO']).to eq('/')
        expect(@request_env['PATH_INFO']).to be_a_kind_of(String)
      end

      it 'sets SCRIPT_NAME correctly' do
        @router.call(Rack::MockRequest.env_for("/sidekiq"))
        expect(@request_env['SCRIPT_NAME']).to eq('/sidekiq')
        expect(@request_env['SCRIPT_NAME']).to be_a_kind_of(String)
      end
    end

    describe 'when from encoded path' do
      it 'sets PATH_INFO correctly' do
        @router.call(Rack::MockRequest.env_for("/sidekiq/queues/some%20path"))
        expect(@request_env['PATH_INFO']).to eq('/queues/some%20path')
        expect(@request_env['PATH_INFO']).to be_a_kind_of(String)
      end

      it 'sets SCRIPT_NAME correctly' do
        @router.call(Rack::MockRequest.env_for("/sidekiq/queues/some%20path"))
        expect(@request_env['SCRIPT_NAME']).to eq('/sidekiq')
        expect(@request_env['SCRIPT_NAME']).to be_a_kind_of(String)
      end
    end
  end
end
