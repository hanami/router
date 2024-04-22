# frozen_string_literal: true

RSpec.describe Hanami::Router do
  let(:router) do
    Hanami::Router.new do
      get '/images', to: 'images.index'
      post '/images', to: 'images.upload'

      get '/images/:id', to: 'images.show'
      post '/images/bulk', to: 'images.upload'
    end
  end

  it "recognize GET" do
    route = router.recognize("/images", method: "GET")
    expect(route.routable?).to be(true)
    expect(route.verb).to eq("GET")
    expect(route.path).to eq("/images")
    expect(route.params).to eq({})
  end

  it "recognizes POST" do
    route = router.recognize("/images", method: "POST")
    expect(route.routable?).to be(true)
    expect(route.verb).to eq("POST")
    expect(route.path).to eq("/images")
    expect(route.params).to eq({})
  end

  describe "with path variables" do
    it "recognize GET with path variable" do
      route = router.recognize("/images/1", method: "GET")
      expect(route.routable?).to be(true)
      expect(route.verb).to eq("GET")
      expect(route.path).to eq("/images/1")
      expect(route.params).to eq({ id: "1" })
    end

    it "recognizes POST with path variable" do
      route = router.recognize("/images/bulk", method: "POST")
      expect(route.routable?).to be(true)
      expect(route.verb).to eq("POST")
      expect(route.path).to eq("/images/bulk")
      expect(route.params).to eq({})
    end
  end
end
