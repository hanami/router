# frozen_string_literal: true

RSpec.describe Hanami::Routing::Resource::Options do
  before do
    @actions = %i[index new create show edit update destroy]
  end

  it "returns all the actions when no exceptions are requested" do
    expect(Hanami::Routing::Resources::Options.new(@actions).actions).to eq(@actions)
  end

  it "returns only the action requested via the :only option" do
    options = Hanami::Routing::Resources::Options.new(@actions, only: :show)
    expect(options.actions).to eq([:show])
  end

  it "returns only the actions requested via the :only options" do
    options = Hanami::Routing::Resources::Options.new(@actions, only: %i[create edit])
    expect(options.actions).to eq(%i[create edit])
  end

  it "returns only the action not rejected via the :except option" do
    options = Hanami::Routing::Resources::Options.new(@actions, except: :destroy)
    expect(options.actions).to eq(%i[index new create show edit update])
  end

  it "returns only the actions requested via the :only options" do
    options = Hanami::Routing::Resources::Options.new(@actions, except: %i[index new edit])
    expect(options.actions).to eq(%i[create show update destroy])
  end

  it "allow access to values" do
    options = Hanami::Routing::Resources::Options.new(@actions, name: :hanami)
    expect(options[:name]).to eq(:hanami)
  end
end
