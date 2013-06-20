require 'test_helper'

describe Lotus::Routing::Resource::Options do
  before do
    @actions = [:index, :new, :create, :show, :edit, :update, :destroy]
  end

  it 'returns all the actions when no exceptions are requested' do
    Lotus::Routing::Resources::Options.new(@actions).actions.must_equal @actions
  end

  it 'returns only the action requested via the :only option' do
    options = Lotus::Routing::Resources::Options.new(@actions, only: :show)
    options.actions.must_equal [:show]
  end

  it 'returns only the actions requested via the :only options' do
    options = Lotus::Routing::Resources::Options.new(@actions, only: [:create, :edit])
    options.actions.must_equal [:create, :edit]
  end

  it 'returns only the action not rejected via the :except option' do
    options = Lotus::Routing::Resources::Options.new(@actions, except: :destroy)
    options.actions.must_equal [:index, :new, :create, :show, :edit, :update]
  end

  it 'returns only the actions requested via the :only options' do
    options = Lotus::Routing::Resources::Options.new(@actions, except: [:index, :new, :edit])
    options.actions.must_equal [:create, :show, :update, :destroy]
  end

  it 'allow access to values' do
    options = Lotus::Routing::Resources::Options.new(@actions, name: :lotus)
    options[:name].must_equal :lotus
  end
end
