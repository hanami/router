RSpec.describe Hanami::Router do
  before do
    @router = Hanami::Router.new(scheme: 'https', host: 'test.com', port: 443)

    @router.get('/hanami',               to: endpoint, as: :fixed)
    @router.get('/flowers/:id',          to: endpoint, as: :variables)
    @router.get('/books/:id', id: /\d+/, to: endpoint, as: :constraints)
    @router.get('/articles(.:format)',   to: endpoint, as: :optional)
    @router.get('/files/*',              to: endpoint, as: :glob)
    @router.resources(:leaves,                         as: :resources)
    @router.resource(:stem,                            as: :singular_resource)
  end

  after do
    @router.reset!
  end

  let(:endpoint) { ->(_env) { [200, {}, ['Hi!']] } }

  describe '#url' do
    it 'recognizes fixed string' do
      expect(@router.url(:fixed)).to eq('https://test.com/hanami')
    end

    it 'recognizes string with variables' do
      expect(@router.url(:variables, id: 'hanami')).to eq('https://test.com/flowers/hanami')
    end

    it "raises error when variables aren't satisfied" do
      expect { @router.url(:variables) }.to raise_error(Hanami::Routing::InvalidRouteException, 'No route (url) could be generated for :variables - please check given arguments')
    end

    it 'recognizes string with variables and constraints' do
      expect(@router.url(:constraints, id: 23)).to eq('https://test.com/books/23')
    end

    it "raises error when constraints aren't satisfied" do
      expect { @router.url(:constraints, id: 'x') }.to raise_error(Hanami::Routing::InvalidRouteException, 'No route (url) could be generated for :constraints - please check given arguments')
    end

    it 'recognizes optional variables' do
      expect(@router.url(:optional)).to eq('https://test.com/articles')
      expect(@router.url(:optional, page: '1')).to eq('https://test.com/articles?page=1')
      expect(@router.url(:optional, format: 'rss')).to eq('https://test.com/articles.rss')
      expect(@router.url(:optional, format: 'rss', page: '1')).to eq('https://test.com/articles.rss?page=1')
    end

    it 'recognizes glob string' do
      expect(@router.url(:glob)).to eq('https://test.com/files/')
    end

    it 'escapes additional params in query string' do
      expect(@router.url(:fixed, return_to: '/dashboard')).to eq('https://test.com/hanami?return_to=%2Fdashboard')
    end

    it 'raises error when insufficient params are passed' do
      expect { @router.url(nil) }.to raise_error(Hanami::Routing::InvalidRouteException, 'No route (url) could be generated for nil - please check given arguments')
    end

    it 'raises error when too many params are passed' do
      expect { @router.url(:fixed, 'x') }.to raise_error(Hanami::Routing::InvalidRouteException, 'HttpRouter::TooManyParametersException - please check given arguments')
    end
  end
end
