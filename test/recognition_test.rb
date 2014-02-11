require 'test_helper'

describe Lotus::Router do
  describe 'recognition' do
    before do
      @router = Lotus::Router.new
      @test   = RecognitionTestCase.new(@router)
    end

    def endpoint(body)
      RecognitionTestCase.endpoint(body)
    end

    describe 'fixed root' do
      before do
        @router.get '/', as: :fixed, to: endpoint('fixed')
      end

      it 'recognizes route(s)' do
        @test.run!([
          [:fixed, '/']
        ])
      end
    end

    describe 'relative variable' do
      before do
        @router.get ':one', as: :variable, to: endpoint('variable')
      end

      it 'recognizes variable(s)' do
        @test.run!([
          [:variable, '/two', {one: 'two'}]
        ])
      end
    end

    describe 'relative unicode variable' do
      before do
        @router.get ':var', as: :variable, to: endpoint('variable')
      end

      it 'recognizes variable(s)' do
        @test.run!([
          [:variable, '/%E6%AE%BA%E3%81%99', {var: '殺す'}]
        ])
      end
    end

    describe 'relative fixed with variable' do
      before do
        @router.get 'test/:one', as: :variable, to: endpoint('variable')
      end

      it 'recognizes route(s)' do
        @test.run!([
          [:variable, '/test/three', {one: 'three'}]
        ])
      end
    end

    describe 'relative fixed and relative variable' do
      before do
        @router.get 'one',  as: :fixed,    to: endpoint('fixed')
        @router.get ':one', as: :variable, to: endpoint('variable')
      end

      it 'recognizes route(s)' do
        @test.run!([
          [:variable, '/two', {one: 'two'}],
          [:fixed, '/one']
        ])
      end
    end

    describe 'relative variable with fixed and relative fixed' do
      before do
        @router.get ':var/one', as: :variable, to: endpoint('variable')
        @router.get 'one',      as: :fixed,    to: endpoint('fixed')
      end

      it 'recognizes route(s)' do
        @test.run!([
          [:variable, '/two/one', {var: 'two'}],
          [:fixed, '/one'],
          [nil, '/two']
        ])
      end
    end

    describe 'fixed with variable and fixed' do
      before do
        @router.get '/foo/:id', as: :variable, to: endpoint('variable')
        @router.get '/foo',     as: :fixed,    to: endpoint('fixed')
      end

      it 'recognizes route(s)' do
        @test.run!([
          [:variable, '/foo/id', {id: 'id'}],
          [:fixed, '/foo']
        ])
      end
    end

    describe 'fixed and variable with fixed' do
      before do
        @router.get '/foo/foo',   as: :fixed,    to: endpoint('fixed')
        @router.get '/:foo/foo2', as: :variable, to: endpoint('variable')
      end

      it 'recognizes route(s)' do
        @test.run!([
          [:variable, '/foo/foo2', {foo: 'foo'}],
          [:fixed, '/foo/foo']
        ])
      end
    end

    describe 'relative variable with constraints' do
      before do
        @router.get ':foo', foo: /(test123|\d+)/, as: :variable, to: endpoint('variable')
      end

      it 'recognizes route(s)' do
        @test.run!([
          [:variable, '/test123', {foo: 'test123'}],
          [:variable, '/123', {foo: '123'}],
          [nil, '/test123andmore'],
          [nil, '/lesstest123']
        ])
      end
    end

    describe 'fixed with format' do
      before do
        @router.get '/test.:format', as: :fixed, to: endpoint('fixed')
      end

      it 'recognizes route(s)' do
        @test.run!([
          [:fixed, '/test.html', {format: 'html'}]
        ])
      end
    end

    describe 'fixed with optional format' do
      before do
        @router.get '/test(.:format)', as: :fixed, to: endpoint('fixed')
      end

      it 'recognizes route(s)' do
        @test.run!([
          [:fixed, '/test.html', {format: 'html'}],
          [:fixed, '/test']
        ])
      end
    end

    describe 'relative optional format' do
      before do
        @router.get '(.:format)', as: :fixed, to: endpoint('fixed')
      end

      it 'recognizes route(s)' do
        @test.run!([
          [:fixed, '/.html', {format: 'html'}],
          [:fixed, '/']
        ])
      end
    end

    describe 'variable with format' do
      before do
        @router.get '/:test.:format', as: :variable, to: endpoint('variable')
      end

      it 'recognizes route(s)' do
        @test.run!([
          [:variable, '/foo.bar', {test: 'foo', format: 'bar'}]
        ])
      end
    end

    describe 'variable with optional format' do
      before do
        @router.get '/:test(.:format)', as: :variable, to: endpoint('variable')
      end

      it 'recognizes route(s)' do
        @test.run!([
          [:variable, '/foo', {test: 'foo'}],
          [:variable, '/foo.bar', {test: 'foo', format: 'bar'}]
        ])
      end
    end

    describe 'variable with optional constrainted format' do
      before do
        @router.get '/:test(.:format)', format: /[^\.]+/, as: :variable, to: endpoint('variable')
      end

      it 'recognizes route(s)' do
        @test.run!([
          [:variable, '/asd@asd.com.json', {test: 'asd@asd.com', format: 'json'}]
        ])
      end
    end
  end
end
