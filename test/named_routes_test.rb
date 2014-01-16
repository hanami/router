describe Lotus::Router do
  before do
    @router = Lotus::Router.new(scheme: 'https', host: 'test.com', port: 443)

    @router.get('/lotus',                  to: endpoint, as: :fixed)
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
      @router.path(:fixed).must_equal '/lotus'
    end

    it 'recognizes string with variables' do
      @router.path(:variables, id: 'lotus').must_equal '/flowers/lotus'
    end

    it "raises error when variables aren't satisfied" do
      -> {
        @router.path(:variables)
      }.must_raise(HttpRouter::InvalidRouteException)
    end

    it 'recognizes string with variables and constraints' do
      @router.path(:constraints, id: 23).must_equal '/books/23'
    end

    it "raises error when constraints aren't satisfied" do
      -> {
        @router.path(:constraints, id: 'x')
      }.must_raise(HttpRouter::InvalidRouteException)
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
      @router.path(:fixed, return_to: '/dashboard').must_equal '/lotus?return_to=%2Fdashboard'
    end

    it 'raises error when insufficient params are passed' do
      -> {
        @router.path(nil)
      }.must_raise(HttpRouter::InvalidRouteException)
    end

    it 'raises error when too many params are passed' do
      -> {
        @router.path(:fixed, 'x')
      }.must_raise(HttpRouter::TooManyParametersException)
    end
  end

  describe '#url' do
    it 'recognizes fixed string' do
      @router.url(:fixed).must_equal 'https://test.com/lotus'
    end

    it 'recognizes string with variables' do
      @router.url(:variables, id: 'lotus').must_equal 'https://test.com/flowers/lotus'
    end

    it "raises error when variables aren't satisfied" do
      -> {
        @router.url(:variables)
      }.must_raise(HttpRouter::InvalidRouteException)
    end

    it 'recognizes string with variables and constraints' do
      @router.url(:constraints, id: 23).must_equal 'https://test.com/books/23'
    end

    it "raises error when constraints aren't satisfied" do
      -> {
        @router.url(:constraints, id: 'x')
      }.must_raise(HttpRouter::InvalidRouteException)
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
      @router.url(:fixed, return_to: '/dashboard').must_equal 'https://test.com/lotus?return_to=%2Fdashboard'
    end

    it 'raises error when insufficient params are passed' do
      -> {
        @router.url(nil)
      }.must_raise(HttpRouter::InvalidRouteException)
    end

    it 'raises error when too many params are passed' do
      -> {
        @router.url(:fixed, 'x')
      }.must_raise(HttpRouter::TooManyParametersException)
    end
  end
end
