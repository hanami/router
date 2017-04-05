RSpec.describe Hanami::Router do
  before do
    @router = Hanami::Router.new(scheme: 'https', host: 'test.com', port: 443)

    @router.get('/hanami',                  to: endpoint, as: :fixed)
    @router.get('/flowers/:id',            to: endpoint, as: :variables)
    @router.get('/books/:id',   id: /\d+/, to: endpoint, as: :constraints)
    @router.get('/articles(.:format)',     to: endpoint, as: :optional)
    @router.get('/files/*',                to: endpoint, as: :glob)
    @router.resources(:leaves,                           as: :resources)
    @router.resource(:stem,                              as: :singular_resource)
  end

  after do
    @router.reset!
  end

  let(:endpoint) { ->(env) { [200, {}, ['Hi!']] } }

  describe '#path' do
    it 'recognizes fixed string' do
      expect(@router.path(:fixed)).to eq('/hanami')
    end

    it 'recognizes string with variables' do
      expect(@router.path(:variables, id: 'hanami')).to eq('/flowers/hanami')
    end

    it "raises error when variables aren't satisfied" do
      exception = expect {@router.path(:variables)}.to raise_error(Hanami::Routing::InvalidRouteException)

      expect(exception.message).to eq('No route (path) could be generated for :variables - please check given arguments')
    end

    it 'recognizes string with variables and constraints' do
      expect(@router.path(:constraints, id: 23)).to eq('/books/23')
    end

    it "raises error when constraints aren't satisfied" do
      exception = expect {@router.path(:constraints, id: 'x')}.to raise_error(Hanami::Routing::InvalidRouteException)

      expect(exception.message).to eq('No route (path) could be generated for :constraints - please check given arguments')
    end

    it 'recognizes optional variables' do
      expect(@router.path(:optional)).to eq('/articles')
      expect(@router.path(:optional, page: '1')).to eq('/articles?page=1')
      expect(@router.path(:optional, format: 'rss')).to eq('/articles.rss')
      expect(@router.path(:optional, format: 'rss', page: '1')).to eq('/articles.rss?page=1')
    end

    it 'recognizes glob string' do
      expect(@router.path(:glob)).to eq('/files/')
    end

    it 'escapes additional params in query string' do
      expect(@router.path(:fixed, return_to: '/dashboard')).to eq('/hanami?return_to=%2Fdashboard')
    end

    it 'raises error when insufficient params are passed' do
      exception = expect {@router.path(nil)}.to raise_error(Hanami::Routing::InvalidRouteException)

      expect(exception.message).to eq('No route (path) could be generated for nil - please check given arguments')
    end

    it 'raises error when too many params are passed' do
      exception = expect {@router.path(:fixed, 'x')}.to raise_error(Hanami::Routing::InvalidRouteException)

      exception.message.to eq('HttpRouter::TooManyParametersException - please check given arguments')
    end

    describe 'plural resource routes' do
      it 'recognizes index' do
        expect(@router.url(:resources)).to eq('https://test.com/leaves')
      end

      it 'recognizes new' do
        expect(@router.url(:new_resource)).to eq('https://test.com/leaves/new')
      end

      it 'recognizes edit' do
        expect(@router.url(:edit_resource, id: 1)).to eq('https://test.com/leaves/1/edit')
      end

      it 'recognizes show' do
        expect(@router.url(:resource, id: 1)).to eq('https://test.com/leaves/1')
      end
    end

    describe 'singular resource routes' do
      it 'recognizes new' do
        expect(@router.url(:new_singular_resource)).to eq('https://test.com/stem/new')
      end

      it 'recognizes edit' do
        expect(@router.url(:edit_singular_resource)).to eq('https://test.com/stem/edit')
      end

      it 'recognizes show' do
        expect(@router.url(:singular_resource)).to eq('https://test.com/stem')
      end
    end
  end

  describe '#url' do
    it 'recognizes fixed string' do
      expect(@router.url(:fixed)).to eq('https://test.com/hanami')
    end

    it 'recognizes string with variables' do
      expect(@router.url(:variables, id: 'hanami')).to eq('https://test.com/flowers/hanami')
    end

    it "raises error when variables aren't satisfied" do
      exception = expect {@router.url(:variables)}.to raise_error(Hanami::Routing::InvalidRouteException)

      expect(exception.message).to eq('No route (url) could be generated for :variables - please check given arguments')
    end

    it 'recognizes string with variables and constraints' do
      expect(@router.url(:constraints, id: 23)).to eq('https://test.com/books/23')
    end

    it "raises error when constraints aren't satisfied" do
      exception = expect {@router.url(:constraints, id: 'x')}.to raise_error(Hanami::Routing::InvalidRouteException)

      expect(exception.message).to eq('No route (url) could be generated for :constraints - please check given arguments')
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
      exception = expect {@router.url(nil)}.to raise_error(Hanami::Routing::InvalidRouteException)

      expect(exception.message).to eq('No route (url) could be generated for nil - please check given arguments')
    end

    it 'raises error when too many params are passed' do
      exception = expect {@router.url(:fixed, 'x')}.to raise_error(Hanami::Routing::InvalidRouteException)

      expect(exception.message).to eq('HttpRouter::TooManyParametersException - please check given arguments')
    end
  end
end
