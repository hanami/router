require 'test_helper'

describe Hanami::Router do
  describe 'generation' do
    before do
      @router = Hanami::Router.new
      @test   = GenerationTestCase.new(@router)
    end

    describe 'variable' do
      before do
        @router.get '/:var', as: :a
      end

      it 'generates relative and absolute URLs' do
        @test.run!([
          [:a, '/test', {var: 'test'}],
          [:a, '/test', {var: 'test'}]
        ])
      end
    end

    describe 'unicode variable' do
      before do
        @router.get '/:var', as: :a
      end

      it 'generates relative and absolute URLs' do
        @test.run!([
          [:a, '/%C3%A4', {var: 'ä'}],
          [:a, '/%C3%A4', ['ä']],
        ])
      end
    end

    describe 'multiple variables' do
      before do
        @router.get '/:var/:baz', as: :a
      end

      it 'generates relative and absolute URLs' do
        @test.run!([
          [:a, '/one/two', {var: 'one', baz: 'two'}],
          [:a, '/one/two', ['one', 'two']]
        ])
      end
    end

    describe 'multiple fixed' do
      before do
        @router.get '/',              as: :a
        @router.get '/test',          as: :b
        @router.get '/test/time',     as: :c
        @router.get '/one/more/what', as: :d
        @router.get '/test.html',     as: :e
      end

      it 'generates relative and absolute URLs' do
        @test.run!([
          [:a, '/'],
          [:b, '/test'],
          [:c, '/test/time'],
          [:d, '/one/more/what'],
          [:e, '/test.html']
        ])
      end
    end

    describe 'fixed with nested param collection' do
      before do
        @router.get '/var', as: :a
      end

      it 'generates relative and absolute URLs' do
        @test.run!([
          [:a, '/var?foo%5B%5D=baz&foo%5B%5D=bar', {foo: ['baz', 'bar']}]
        ])
      end
    end

    describe 'fixed with multi-nested params' do
      before do
        @router.get '/var', as: :a
      end

      it 'generates relative and absolute URLs' do
        @test.run!([
          [:a, '/var?foo%5Baz%5D=baz', {foo: {az: 'baz'}}]
        ])
      end
    end

    describe 'fixed with multi-nested param collection' do
      before do
        @router.get '/var', as: :a
      end

      it 'generates relative and absolute URLs' do
        @test.run!([
          [:a, '/var?foo%5Baz%5D%5B%5D=baz', {foo: {az: ['baz']}}]
        ])
      end
    end

    describe 'variable with query string' do
      before do
        @router.get '/:var', as: :a
      end

      it 'generates relative and absolute URLs' do
        @test.run!([
          [:a, '/test?query=string', {var: 'test', query: 'string'}],
          [:a, '/test?query=string', ['test', {query: 'string'}]]
        ])
      end
    end

    describe 'fixed with mandatory format' do
      before do
        @router.get '/test.:format', as: :a
      end

      it 'generates relative and absolute URLs' do
        @test.run!([
          [:a, '/test.html', {format: 'html'}],
          [:a, '/test.html', ['html']]
        ])
      end
    end

    describe 'fixed with optional format' do
      before do
        @router.get '/test(.:format)', as: :a
      end

      it 'generates relative and absolute URLs' do
        @test.run!([
          [:a, '/test.html', {format: 'html'}],
          [:a, '/test.html', ['html']],
          [:a, '/test']
        ])
      end
    end

    describe 'variable with mandatory format' do
      before do
        @router.get '/:var.:format', as: :a
      end

      it 'generates relative and absolute URLs' do
        @test.run!([
          [:a, '/test.html', {var: 'test', format: 'html'}],
          [:a, '/test.html', ['test', 'html']],
          # [:a, '/test.html', ['test', {format: 'html'}]],
          # [:a, '/test.html', {format: 'html'}]
        ])
      end
    end

    describe 'variable with optional format' do
      before do
        @router.get '/:var(.:format)', as: :a
      end

      it 'generates relative and absolute URLs' do
        @test.run!([
          [:a, '/test.html', {var: 'test', format: 'html'}],
          [:a, '/test.html', ['test', 'html']],
          # [:a, '/test.html', ['test', {format: 'html'}]],
          [:a, '/test', ['test']],
          [:a, '/test', {var: 'test'}],
          # [:a, nil, {format: 'html'}],
          # [:a, nil]
        ])
      end
    end

    describe 'variable with optional variable' do
      before do
        @router.get '/:var1(/:var2)', as: :a
      end

      it 'generates relative and absolute URLs' do
        @test.run!([
          [:a, '/foo/bar', {var1: 'foo', var2: 'bar'}],
          # [:a, nil, ['foo', {var1: 'bar'}]],
          [:a, '/foo', {var1: 'foo'}],
          [:a, '/foo', ['foo']],
          [:a, '/foo', ['foo', nil]],
        ])
      end
    end

    describe 'variable with optional variable and format' do
      before do
        @router.get '/:var1(/:var2.:format)', as: :a
      end

      it 'generates relative and absolute URLs' do
        @test.run!([
          [:a, '/test/test2.html', {var1: 'test', var2: 'test2', format: 'html'}],
          # [:a, '/test/test2.html', ['test', 'test2', 'html']],
          [:a, '/test', ['test']],
        ])
      end
    end

    describe 'variable with optional nested variables' do
      before do
        @router.get '/:var1(/:var2(/:var3))', as: :a
      end

      it 'generates relative and absolute URLs' do
        @test.run!([
          [:a, '/var/fooz/baz', {var1: 'var', var2: 'fooz', var3: 'baz'}],
          [:a, '/var/fooz', {var1: 'var', var2: 'fooz'}],
          [:a, '/var', {var1: 'var'}],
          # [:a, '/var/fooz/baz', ['var', 'fooz', 'baz']],
          [:a, '/var/fooz', ['var', 'fooz']],
          [:a, '/var', ['var']],
        ])
      end
    end
  end
end
