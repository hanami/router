require 'test_helper'

describe Lotus::Routing::RouteSet do
  before do
    @routes = Lotus::Routing::RouteSet.new
  end

  describe '#add' do
    before do
      @routes.add route
    end

    let(:endpoint) { Object.new }

    describe 'when a fixed route is passed' do
      let(:route) { Lotus::Routing::Route.new(path: '/', options: {endpoint: endpoint}) }

      it 'should be added in the fixed route set' do
        @routes.routes['get'][:fixed].values.must_include endpoint
        @routes.routes['head'][:fixed].values.must_include endpoint
      end
    end
  end
end
