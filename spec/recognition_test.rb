require 'test_helper'

describe Hanami::Router do
  describe 'recognition' do
    before do
      @router = Hanami::Router.new
      @test   = RecognitionTestCase.new(@router)
    end

    def endpoint(body)
      RecognitionTestCase.endpoint(body)
    end

    describe 'empty path' do
      before do
        @router.get '', as: :empty, to: endpoint('empty')
      end

      it 'recognizes route(s)' do
        @test.run!([
          [:empty, '/'],
          [:empty, '']
        ])
      end
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

    describe 'one fixed segment' do
      before do
        @router.get '/test', as: :fixed, to: endpoint('fixed')
      end

      it 'recognizes route(s)' do
        @test.run!([
          [:fixed, '/test']
        ])
      end
    end

    describe 'two fixed segments' do
      before do
        @router.get '/test/one', as: :fixed, to: endpoint('fixed')
      end

      it 'recognizes route(s)' do
        @test.run!([
          [:fixed, '/test/one']
        ])
      end
    end

    describe 'three fixed segments' do
      before do
        @router.get '/test/one/two', as: :fixed, to: endpoint('fixed')
      end

      it 'recognizes route(s)' do
        @test.run!([
          [:fixed, '/test/one/two']
        ])
      end
    end

    describe 'one fixed segment with format' do
      before do
        @router.get '/test.html', as: :fixed, to: endpoint('fixed')
      end

      it 'recognizes route(s)' do
        @test.run!([
          [:fixed, '/test.html']
        ])
      end
    end

    describe 'only format' do
      before do
        @router.get '.html', as: :fixed, to: endpoint('fixed')
      end

      it 'recognizes route(s)' do
        @test.run!([
          [:fixed, '/.html']
        ])
      end
    end

    describe 'fixed unicode' do
      before do
        @router.get '/føø', as: :fixed, to: endpoint('fixed')
      end

      it 'recognizes route(s)' do
        @test.run!([
          [:fixed, '/f%C3%B8%C3%B8']
        ])
      end
    end

    describe 'globbed' do
      before do
        @router.get '/*', as: :globbed, to: endpoint('globbed')
      end

      it 'recognizes route(s)' do
        @test.run!([
          [:globbed, '/optional'],
          [:globbed, '/']
        ])
      end
    end

    describe 'multiple globbed routes' do
      before do
        @router.get '/test*', as: :globbed, to: endpoint('globbed')
        @router.get '/*',     as: :root,    to: endpoint('root')
      end

      it 'recognizes route(s)' do
        @test.run!([
          [:globbed, '/test/optional'],
          [:globbed, '/test/optional/'],
          [:root, '/testing/optional']
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

    describe 'fixed with globbed variable' do
      before do
        @router.get '/test/*variable', as: :globbed_variable, to: endpoint('globbed_variable')
      end

      it 'recognizes route(s)' do
        @test.run!([
          [:globbed_variable, '/test/one/two/three', {variable: ['one', 'two', 'three']}]
        ])
      end
    end

    describe 'relative fixed with globbed variable and fixed nested resource' do
      before do
        @router.get 'test/*variable/test', as: :globbed_variable, to: endpoint('globbed_variable')
      end

      it 'recognizes route(s)' do
        @test.run!([
          [:globbed_variable, '/test/one/two/three/test', {variable: ['one', 'two', 'three']}],
          [nil, '/test/one/two/three']
        ])
      end
    end

    describe 'relative fixed with globbed variable, with nested resource and globbed variable' do
      before do
        @router.get 'test/*variable/test/*variable2', as: :globbed_variables, to: endpoint('globbed_variables')
      end

      it 'recognizes route(s)' do
        @test.run!([
          [:globbed_variables, '/test/one/two/three/test/four/five/six', {variable: ['one', 'two', 'three'], variable2: ['four', 'five', 'six']}],
          [nil, '/test/one/two/three']
        ])
      end
    end

    describe 'fixed with variable and globbed variable in the same segment, plus format' do
      before do
        @router.get '/test/:test-*variable.:format', as: :variables, to: endpoint('variables')
      end

      it 'recognizes route(s)' do
        @test.run!([
          [:variables, '/test/one-two/three/four/five.six', {test: 'one', variable: ['two', 'three','four', 'five'], format: 'six'}]
        ])
      end
    end

    describe 'relative fixed with constrainted globbed variable' do
      before do
        @router.get 'test/*variable', as: :globbed_variable, variable: /[a-z]+/, to: endpoint('globbed_variable')
      end

      it 'recognizes route(s)' do
        @test.run!([
          [nil, '/test/asd/123'],
          [nil, '/test/asd/asd123'],
          [:globbed_variable, '/test/asd/qwe', {variable: ['asd', 'qwe']}]
        ])
      end
    end

    describe 'relative fixed with constrainted globbed variable and fixed nested resource' do
      before do
        @router.get 'test/*variable/test', as: :globbed_variable, variable: /[a-z]+/, to: endpoint('globbed_variable')
      end

      it 'recognizes route(s)' do
        @test.run!([
          [nil, '/test/asd/123'],
          [nil, '/test/asd/asd123'],
          [nil, '/test/asd/qwe'],
          [:globbed_variable, '/test/asd/qwe/test', {variable: ['asd', 'qwe']}]
        ])
      end
    end

    describe 'relative fixed with constrainted globbed variable and variable nested resource' do
      before do
        @router.get 'test/*variable/:test', as: :globbed_variable, variable: /[a-z]+/, to: endpoint('globbed_variable')
      end

      it 'recognizes route(s)' do
        @test.run!([
          [:globbed_variable, '/test/asd/qwe/help', {variable: ['asd', 'qwe'], test: 'help'}]
        ])
      end
    end

    describe 'relative fixed with globbed variable and format' do
      before do
        @router.get 'test/*variable.:format', as: :globbed_variable, to: endpoint('globbed_variable')
      end

      it 'recognizes route(s)' do
        @test.run!([
          [:globbed_variable, '/test/asd/qwe.html', {variable: ['asd', 'qwe'], format: 'html'}]
        ])
      end
    end

    describe 'relative fixed with constrainted globbed variable and format' do
      before do
        @router.get 'test/*variable.:format', as: :globbed_variable, variable: /[a-z]+/, to: endpoint('globbed_variable')
      end

      it 'recognizes route(s)' do
        @test.run!([
          [nil, '/test/asd/123'],
          [nil, '/test/asd/asd123'],
          [nil, '/test/asd/qwe'],
          [:globbed_variable, '/test/asd/qwe.html', {variable: ['asd', 'qwe'], format: 'html'}]
        ])
      end
    end

    describe 'relative fixed with constrainted globbed variable and optional format' do
      before do
        @router.get 'test/*variable(.:format)', as: :globbed_variable, variable: /[a-z]+/, to: endpoint('globbed_variable')
      end

      it 'recognizes route(s)' do
        @test.run!([
          [nil, '/test/asd/123'],
          [nil, '/test/asd/asd123'],
          [:globbed_variable, '/test/asd/qwe', {variable: ['asd', 'qwe']}],
          [:globbed_variable, '/test/asd/qwe.html', {variable: ['asd', 'qwe'], format: 'html'}]
        ])
      end
    end

    describe 'relative fixed with globbed variable and fixed format' do
      before do
        @router.get 'test/*variable.html', as: :globbed_variable, to: endpoint('globbed_variable')
      end

      it 'recognizes route(s)' do
        @test.run!([
          [nil, '/test/asd/123'],
          [:globbed_variable, '/test/asd/qwe.html', {variable: ['asd', 'qwe']}]
        ])
      end
    end

    describe 'multiple routes with variables, constraints and verbs' do
      before do
        @router.get  '/:common_variable/:matched',   as: :regex,   matched: /\d+/, to: endpoint('regex')
        @router.post '/:common_variable/:matched',   as: :post,                    to: endpoint('post')
        @router.get  '/:common_variable/:unmatched', as: :noregex,                 to: endpoint('noregex')
      end

      it 'recognizes route(s)' do
        @test.run!([
          [:regex, '/common/123', {common_variable: 'common', matched: '123'}],
          [:noregex, '/common/other', {common_variable: 'common', unmatched: 'other'}],
          [:post, '/common/123', {common_variable: 'common', matched: '123'}, 'POST'],
          [:post, '/common/other', {common_variable: 'common', matched: 'other'}, 'POST']
        ])
      end
    end

    describe 'multiple routes with variables and constraints' do
      before do
        @router.get ':test/number',   as: :regex,  test: /\d+/, to: endpoint('regex')
        @router.get ':test/anything', as: :greedy,              to: endpoint('greedy')
      end

      it 'recognizes route(s)' do
        @test.run!([
          [:regex, '/123/number', {test: '123'}],
          [:greedy, '/123/anything', {test: '123'}]
        ])
      end
    end

    describe 'relative variable with permissive constraint' do
      before do
        @router.get ':test', as: :regex, test: /.*/, to: endpoint('regex')
      end

      it 'recognizes route(s)' do
        @test.run!([
          [:regex, '/test/', {test: 'test/'}]
        ])
      end
    end

    describe 'variable with permissive constraint' do
      before do
        @router.get '/:test', as: :regex, test: /.*/, to: endpoint('regex')
      end

      it 'recognizes route(s)' do
        @test.run!([
          [:regex, '/test.html', {test: 'test.html'}]
        ])
      end
    end

    describe 'relative variable with numeric constraint' do
      before do
        @router.get ':test', as: :regex, test: /\d+/, to: endpoint('regex')
      end

      it 'recognizes route(s)' do
        @test.run!([
          [:regex, '/123', {test: '123'}],
          [nil, '/a123']
        ])
      end
    end

    describe 'multiple nested optional fixed segments' do
      before do
        @router.get 'one(/two(/three(/four)(/five)))', as: :nested, to: endpoint('nested')
      end

      it 'recognizes route(s)' do
        @test.run!([
          [:nested, '/one'],
          [:nested, '/one/two'],
          [:nested, '/one/two/three'],
          [:nested, '/one/two/three/four'],
          [:nested, '/one/two/three/five'],
          [:nested, '/one/two/three/four/five'],
          [nil, '/one/two/four/five']
        ])
      end
    end

    describe 'relative fixed with escaped variable' do
      before do
        @router.get "test\\:variable", as: :escaped, to: endpoint('escaped')
      end

      it 'recognizes route(s)' do
        @test.run!([
          [:escaped, '/test:variable']
        ])
      end
    end

    describe 'relative fixed with escaped optional variable' do
      before do
        @router.get "test\\(:variable\\)", as: :escaped, to: endpoint('escaped')
      end

      it 'recognizes route(s)' do
        @test.run!([
          [:escaped, '/test(hello)', {variable: 'hello'}]
        ])
      end
    end

    describe 'relative fixed with escaped globbed variable' do
      before do
        @router.get "test\\*variable", as: :escaped, to: endpoint('escaped')
      end

      it 'recognizes route(s)' do
        @test.run!([
          [:escaped, '/test*variable']
        ])
      end
    end

    describe 'relative fixed with escaped glob' do
      before do
        @router.get "testvariable\\*", as: :escaped, to: endpoint('escaped')
      end

      it 'recognizes route(s)' do
        @test.run!([
          [:escaped, '/testvariable*']
        ])
      end
    end

    describe 'variable sourrounded by fixed tokens in the same segment' do
      before do
        @router.get '/one-:variable-time', as: :variable, to: endpoint('variable')
      end

      it 'recognizes route(s)' do
        @test.run!([
          [:variable, '/one-value-time', {variable: 'value'}]
        ])
      end
    end

    describe 'constrainted variable sourrounded by fixed tokens in the same segment' do
      before do
        @router.get '/one-:variable-time', as: :variable, variable: /\d+/, to: endpoint('variable')
      end

      it 'recognizes route(s)' do
        @test.run!([
          [:variable, '/one-123-time', {variable: '123'}],
          [nil, '/one-value-time']
        ])
      end
    end

    describe 'variable sourrounded by fixed token and format in the same segment' do
      before do
        @router.get 'hey.:greed.html', as: :variable, to: endpoint('variable')
      end

      it 'recognizes route(s)' do
        @test.run!([
          [:variable, '/hey.greedybody.html', {greed: 'greedybody'}]
        ])
      end
    end

    describe 'multiple routes with variables in the same segment' do
      before do
        @router.get '/:v1-:v2-:v3-:v4-:v5-:v6', as: :var6, to: endpoint('var6')
        @router.get '/:v1-:v2-:v3-:v4-:v5',     as: :var5, to: endpoint('var5')
        @router.get '/:v1-:v2-:v3-:v4',         as: :var4, to: endpoint('var4')
        @router.get '/:v1-:v2-:v3',             as: :var3, to: endpoint('var3')
        @router.get '/:v1-:v2',                 as: :var2, to: endpoint('var2')
        @router.get '/:v1',                     as: :var1, to: endpoint('var1')
      end

      it 'recognizes route(s)' do
        @test.run!([
          [:var1, '/one', {v1: 'one'}],
          [:var2, '/one-two', {v1: 'one', v2: 'two'}],
          [:var3, '/one-two-three', {v1: 'one', v2: 'two', v3: 'three'}],
          [:var4, '/one-two-three-four', {v1: 'one', v2: 'two', v3: 'three', v4: 'four'}],
          [:var5, '/one-two-three-four-five', {v1: 'one', v2: 'two', v3: 'three', v4: 'four', v5: 'five'}],
          [:var6, '/one-two-three-four-five-six', {v1: 'one', v2: 'two', v3: 'three', v4: 'four', v5: 'five', v6: 'six'}]
        ])
      end
    end

    describe 'variable sourrounded by fixed token and format in the same segment' do
      before do
        @router.get '/:common_variable.:matched',   as: :regex, matched: /\d+/, to: endpoint('regex')
        @router.get '/:common_variable.:unmatched', as: :noregex,               to: endpoint('noregex')
      end

      it 'recognizes route(s)' do
        @test.run!([
          [:regex, '/common.123', {common_variable: 'common', matched: '123'}],
          [:noregex, '/common.other', {common_variable: 'common', unmatched: 'other'}]
        ])
      end
    end

    describe '#define' do
      before do
        endpoint = endpoint('defined_variable')

        @router.define do
          get '/foo/:id', as: :variable, to: endpoint
        end
      end

      it 'recognizes route(s) in the define block' do
        @test.run!([
          [:defined_variable, '/foo/id', {id: 'id'}]
        ])
      end
    end
  end
end
