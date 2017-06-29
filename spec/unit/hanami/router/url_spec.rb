RSpec.describe Hanami::Router do
  let(:router) do
    e = endpoint
    Hanami::Router.new(scheme: 'https', host: 'test.com', port: 443) do
      get '/hanami',               to: e, as: :fixed
      get '/flowers/:id',          to: e, as: :variables
      get '/books/:id', id: /\d+/, to: e, as: :constraints
      get '/articles(.:format)',   to: e, as: :optional
      get '/files/*glob',          to: e, as: :glob
      resources :leaves,                  as: :resources
      resource :stem,                     as: :singular_resource
    end
  end

  let(:endpoint) { ->(_env) { [200, {}, ['Hi!']] } }

  describe '#url' do
    it 'recognizes fixed string' do
      expect(router.url(:fixed)).to eq('https://test.com/hanami')
    end

    it 'recognizes string with variables' do
      expect(router.url(:variables, id: 'hanami')).to eq('https://test.com/flowers/hanami')
    end

    it "raises error when variables aren't satisfied" do
      expect { router.url(:variables) }.to raise_error(Hanami::Routing::InvalidRouteException, 'cannot expand with keys [], possible expansions: [:id]')
    end

    it 'recognizes string with variables and constraints' do
      expect(router.url(:constraints, id: 23)).to eq('https://test.com/books/23')
    end

    it 'recognizes optional variables' do
      expect(router.url(:optional)).to eq('https://test.com/articles')
      expect(router.url(:optional, page: '1')).to eq('https://test.com/articles?page=1')
      expect(router.url(:optional, format: 'rss')).to eq('https://test.com/articles.rss')
      expect(router.url(:optional, format: 'rss', page: '1')).to eq('https://test.com/articles.rss?page=1')
    end

    it 'recognizes glob string' do
      expect(router.url(:glob)).to eq('https://test.com/files/')
    end

    it 'escapes additional params in query string' do
      expect(router.url(:fixed, return_to: '/dashboard')).to eq('https://test.com/hanami?return_to=%2Fdashboard')
    end

    it 'raises error when insufficient params are passed' do
      expect { router.url(nil) }.to raise_error(Hanami::Routing::InvalidRouteException, 'No route could be generated for nil - please check given arguments')
    end

    context 'plural resource routes' do
      it 'recognizes index' do
        expect(router.url(:resources)).to eq('https://test.com/leaves')
      end

      it 'recognizes new' do
        expect(router.url(:new_resource)).to eq('https://test.com/leaves/new')
      end

      it 'recognizes edit' do
        expect(router.url(:edit_resource, id: 1)).to eq('https://test.com/leaves/1/edit')
      end

      it 'recognizes show' do
        expect(router.url(:resource, id: 1)).to eq('https://test.com/leaves/1')
      end
    end

    context 'singular resource routes' do
      it 'recognizes new' do
        expect(router.url(:new_singular_resource)).to eq('https://test.com/stem/new')
      end

      it 'recognizes edit' do
        expect(router.url(:edit_singular_resource)).to eq('https://test.com/stem/edit')
      end

      it 'recognizes show' do
        expect(router.url(:singular_resource)).to eq('https://test.com/stem')
      end
    end
  end
end
