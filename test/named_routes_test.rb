require 'test_helper'

describe Hanami::Router do
  before do
    @router = Hanami::Router.new(scheme: 'https', host: 'test.com', port: 443)

    @router.get('/hanami',                  to: endpoint, as: :fixed)
    @router.get('/flowers/:id',            to: endpoint, as: :variables)
    @router.get('/books/:id',   id: /\d+/, to: endpoint, as: :constraints)
    @router.get('/articles(.:format)',     to: endpoint, as: :optional)
    @router.get('/files/*',                to: endpoint, as: :glob)
  end

  after do
    @router.reset!
  end

  let(:endpoint) { ->(env) { [200, {}, ['Hi!']] } }

  describe '#path' do
    it 'recognizes fixed string' do
      @router.path(:fixed).must_equal '/hanami'
    end

    it 'recognizes string with variables' do
      @router.path(:variables, id: 'hanami').must_equal '/flowers/hanami'
    end

    it "raises error when variables aren't satisfied" do
      exception = -> {
        @router.path(:variables)
      }.must_raise(Hanami::Routing::InvalidRouteException)

      exception.message.must_equal 'No route (path) could be generated for :variables - please check given arguments'
    end

    it 'recognizes string with variables and constraints' do
      @router.path(:constraints, id: 23).must_equal '/books/23'
    end

    it "raises error when constraints aren't satisfied" do
      exception = -> {
        @router.path(:constraints, id: 'x')
      }.must_raise(Hanami::Routing::InvalidRouteException)

      exception.message.must_equal 'No route (path) could be generated for :constraints - please check given arguments'
    end

    it 'recognizes optional variables' do
      @router.path(:optional).must_equal                           '/articles'
      @router.path(:optional, page: '1').must_equal                '/articles?page=1'
      @router.path(:optional, format: 'rss').must_equal            '/articles.rss'
      @router.path(:optional, format: 'rss', page: '1').must_equal '/articles.rss?page=1'
    end

    it 'recognizes glob string' do
      @router.path(:glob).must_equal '/files/'
    end

    it 'escapes additional params in query string' do
      @router.path(:fixed, return_to: '/dashboard').must_equal '/hanami?return_to=%2Fdashboard'
    end

    it 'raises error when insufficient params are passed' do
      exception = -> {
        @router.path(nil)
      }.must_raise(Hanami::Routing::InvalidRouteException)

      exception.message.must_equal 'No route (path) could be generated for nil - please check given arguments'
    end

    it 'raises error when too many params are passed' do
      exception = -> {
        @router.path(:fixed, 'x')
      }.must_raise(Hanami::Routing::InvalidRouteException)

      exception.message.must_equal 'HttpRouter::TooManyParametersException - please check given arguments'
    end
  end

  describe '#url' do
    it 'recognizes fixed string' do
      @router.url(:fixed).must_equal 'https://test.com/hanami'
    end

    it 'recognizes string with variables' do
      @router.url(:variables, id: 'hanami').must_equal 'https://test.com/flowers/hanami'
    end

    it "raises error when variables aren't satisfied" do
      exception = -> {
        @router.url(:variables)
      }.must_raise(Hanami::Routing::InvalidRouteException)

      exception.message.must_equal 'No route (url) could be generated for :variables - please check given arguments'
    end

    it 'recognizes string with variables and constraints' do
      @router.url(:constraints, id: 23).must_equal 'https://test.com/books/23'
    end

    it "raises error when constraints aren't satisfied" do
      exception = -> {
        @router.url(:constraints, id: 'x')
      }.must_raise(Hanami::Routing::InvalidRouteException)

      exception.message.must_equal 'No route (url) could be generated for :constraints - please check given arguments'
    end

    it 'recognizes optional variables' do
      @router.url(:optional).must_equal                           'https://test.com/articles'
      @router.url(:optional, page: '1').must_equal                'https://test.com/articles?page=1'
      @router.url(:optional, format: 'rss').must_equal            'https://test.com/articles.rss'
      @router.url(:optional, format: 'rss', page: '1').must_equal 'https://test.com/articles.rss?page=1'
    end

    it 'recognizes glob string' do
      @router.url(:glob).must_equal 'https://test.com/files/'
    end

    it 'escapes additional params in query string' do
      @router.url(:fixed, return_to: '/dashboard').must_equal 'https://test.com/hanami?return_to=%2Fdashboard'
    end

    it 'raises error when insufficient params are passed' do
      exception = -> {
        @router.url(nil)
      }.must_raise(Hanami::Routing::InvalidRouteException)

      exception.message.must_equal 'No route (url) could be generated for nil - please check given arguments'
    end

    it 'raises error when too many params are passed' do
      exception = -> {
        @router.url(:fixed, 'x')
      }.must_raise(Hanami::Routing::InvalidRouteException)

      exception.message.must_equal 'HttpRouter::TooManyParametersException - please check given arguments'
    end
  end
end
