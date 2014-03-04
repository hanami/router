require 'test_helper'

describe Lotus::Routing::Route do
  describe '#initialize' do
    describe 'passing an endpoint' do
      before do
        @endpoint = Object.new
        @route    = Lotus::Routing::Route.new(options: {endpoint: @endpoint})
      end

      it 'is set' do
        @route._endpoint.must_equal @endpoint
      end
    end
  end

  describe '#_path' do
    before do
      @route = Lotus::Routing::Route.new(path: '/ok')
    end

    it 'has exposes a getter' do
      @route._path.must_equal '/ok'
    end
  end

  describe '#_verbs' do
    describe 'when not specified' do
      before do
        @route = Lotus::Routing::Route.new
      end

      it 'they are set to the default' do
        @route._verbs.must_equal [:get, :head]
      end
    end

    describe 'when specified' do
      before do
        @route = Lotus::Routing::Route.new(verbs: :post)
      end

      it 'has exposes a getter' do
        @route._verbs.must_equal [:post]
      end
    end
  end
end
