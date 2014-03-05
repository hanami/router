require 'test_helper'

describe Lotus::Routing::Path do
  before do
    @path = Lotus::Routing::Path.new(path, options)
  end

  let(:options) { Hash[] }

  describe '#fixed?' do
    describe 'when initialized with a fixed path' do
      let(:path) { '/' }

      it 'is fixed' do
        @path.must_be :fixed?
      end
    end

    describe 'when initialized with a fixed path and multiple segments' do
      let(:path) { '/a/b' }

      it 'is fixed' do
        @path.must_be :fixed?
      end
    end

    describe 'when initialized with a variable' do
      let(:path) { '/:var' }

      it "isn't fixed" do
        @path.wont_be :fixed?
      end
    end

    describe 'when initialized with a globbed variable' do
      let(:path) { '/*var' }

      it "isn't fixed" do
        @path.wont_be :fixed?
      end
    end

    describe 'when initialized with an optional variable' do
      let(:path) { '/(:var)' }

      it "isn't fixed" do
        @path.wont_be :fixed?
      end
    end

    describe 'when initialized with an optional variable with dot' do
      let(:path) { '/(.:var)' }

      it "isn't fixed" do
        @path.wont_be :fixed?
      end
    end

    # describe 'when initialized with nested optional variables' do
    #   let(:path) { '/(var1(/var2))' }

    #   it "isn't fixed" do
    #     @path.wont_be :fixed?
    #   end
    # end

    # describe 'when initialized with multi-nested optional variables' do
    #   let(:path) { '/(var1(/var2(/var3)))' }

    #   it "isn't fixed" do
    #     @path.wont_be :fixed?
    #   end
    # end

#     describe 'when initialized with escaped variable' do
#       let(:path) { '/test\\:variable' }

#       it 'is fixed'
#       # it 'is fixed' do
#       #   @path.must_be :fixed?
#       # end
#     end

#     describe 'when initialized with escaped optional variable' do
#       let(:path) { '/test\(:variable\)' }

#       it 'is fixed'
#       # it 'is fixed' do
#       #   @path.must_be :fixed?
#       # end
#     end
  end

  describe '#compiled' do
    describe 'when initialized with a fixed path' do
      let(:path) { '/' }

      it 'returns compiled path' do
        @path.compiled.must_be_nil
      end
    end

    describe 'when initialized with a variable' do
      let(:path) { '/:var' }

      it 'returns compiled path' do
        compiled = @path.compiled

        compiled.must_equal(/\A\/(?-mix:(?<var>[a-z0-9_]+))\z/)

        match = compiled.match('/hello')
        match.wont_be_nil
        match[:var].must_equal 'hello'
      end
    end

    describe 'when initialized with two variables' do
      let(:path) { '/accounts/:account_id/people/:id' }

      it 'returns compiled path' do
        compiled = @path.compiled

        compiled.must_equal(/\A\/accounts\/(?-mix:(?<account_id>[a-z0-9_]+))\/people\/(?-mix:(?<id>[a-z0-9_]+))\z/)

        match = compiled.match('/accounts/1/people/23')
        match.wont_be_nil

        match[:account_id].must_equal '1'
        match[:id].must_equal '23'
      end
    end

    describe 'when initialized with a constrainted variable' do
      let(:path)    { '/:var' }
      let(:options) { Hash[var: /[0-9]+/] }

      it 'returns compiled path' do
        compiled = @path.compiled

        compiled.must_equal(/\A\/(?-mix:(?<var>(?-mix:[0-9]+)))\z/)

        compiled.match('/hello').must_be_nil

        match = compiled.match('/23')
        match.wont_be_nil
        match[:var].must_equal '23'
      end
    end

    describe 'when initialized with a globbed variable' do
      let(:path) { '/*var' }

      it 'returns compiled path' do
        compiled = @path.compiled

        compiled.must_equal(/\A\/(?-mix:(?<var>(.*?)))\z/)

        match = compiled.match('/all-the-things')
        match.wont_be_nil
        match[:var].must_equal 'all-the-things'
      end
    end

    describe 'when initialized with an optional variable' do
      let(:path) { '/(:var)' }

      it 'returns compiled path' do
        compiled = @path.compiled

        compiled.must_equal(/\A\/(?-mix:(?<var>[a-z0-9_]*))\z/)

        match = compiled.match('/')
        match.wont_be_nil
        match[:var].must_equal ''

        match = compiled.match('/hello')
        match.wont_be_nil
        match[:var].must_equal 'hello'
      end
    end

    describe 'when initialized with an optional variable with dot' do
      let(:path) { '/articles(.:format)' }

      it 'returns compiled path' do
        compiled = @path.compiled

        compiled.must_equal(/\A\/articles(?-mix:[\.]*(?<format>[a-z0-9_]*))\z/)

        match = compiled.match('/articles')
        match.wont_be_nil
        match[:format].must_equal ''

        match = compiled.match('/articles.json')
        match.wont_be_nil
        match[:format].must_equal 'json'
      end
    end

    describe 'when initialized with fixed with variable and globbed variable in the same segment, plus format' do
      let(:path) { '/test/:test-*variable.:format' }

      it 'returns compiled path' do
        compiled = @path.compiled

        compiled.must_equal(/\A\/test\/(?-mix:(?<test>[a-z0-9_]+))-(?-mix:(?<variable>(.*?)))(?-mix:(?<format>[a-z0-9_]+))\z/)

        match = compiled.match('/test/one-two/three/four/five.six')
        match.wont_be_nil
        match[:test].must_equal 'one'
        match[:variable].must_equal 'two/three/four/five.'
        match[:format].must_equal 'six'
      end
    end

#     describe 'when initialized with nested optional variables' do
#       let(:path) { '/(var1(/var2))' }

#       it "isn't fixed" do
#         @path.wont_be :fixed?
#       end
#     end

#     describe 'when initialized with multi-nested optional variables' do
#       let(:path) { '/(var1(/var2(/var3)))' }

#       it "isn't fixed" do
#         @path.wont_be :fixed?
#       end
#     end

#     describe 'when initialized with escaped variable' do
#       let(:path) { '/test\\:variable' }

#       it 'is fixed'
#       # it 'is fixed' do
#       #   @path.must_be :fixed?
#       # end
#     end

#     describe 'when initialized with escaped optional variable' do
#       let(:path) { '/test\(:variable\)' }

#       it 'is fixed'
#       # it 'is fixed' do
#       #   @path.must_be :fixed?
#       # end
#     end
  end
end
