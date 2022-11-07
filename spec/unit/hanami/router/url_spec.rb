# frozen_string_literal: true

RSpec.describe Hanami::Router do
  let(:router) do
    e = endpoint
    Hanami::Router.new(base_url: base_url) do
      get "/hanami",               to: e, as: :fixed
      get "/flowers/:id",          to: e, as: :variables
      get "/books/:id", id: /\d+/, to: e, as: :constraints
      get "/articles(.:format)",   to: e, as: :optional
      get "/files/*glob",          to: e, as: :glob
    end
  end

  let(:endpoint) { ->(*) { [200, {}, ["Hi!"]] } }
  let(:base_url) { "https://hanami.test" }

  describe "#url" do
    it "recognizes fixed string" do
      expect(router.url(:fixed)).to eq("#{base_url}/hanami")
    end

    it "recognizes string with variables" do
      expect(router.url(:variables, id: "hanami")).to eq("#{base_url}/flowers/hanami")
    end

    it "raises error when variables aren't satisfied" do
      expect { router.url(:variables) }.to raise_error(Hanami::Router::InvalidRouteExpansionError, "No route could be generated for `:variables': cannot expand with keys [], possible expansions: [:id]")
    end

    it "recognizes string with variables and constraints" do
      expect(router.url(:constraints, id: 23)).to eq("#{base_url}/books/23")
    end

    it "recognizes optional variables" do
      expect(router.url(:optional)).to eq("#{base_url}/articles")
      expect(router.url(:optional, page: "1")).to eq("#{base_url}/articles?page=1")
      expect(router.url(:optional, format: "rss")).to eq("#{base_url}/articles.rss")
      expect(router.url(:optional, format: "rss", page: "1")).to eq("#{base_url}/articles.rss?page=1")
    end

    it "recognizes glob string" do
      expect(router.url(:glob)).to eq("#{base_url}/files/")
    end

    it "escapes additional params in query string" do
      expect(router.url(:fixed, return_to: "/dashboard")).to eq("#{base_url}/hanami?return_to=%2Fdashboard")
    end

    # FIXME: should preserve this behavior?
    xit "raises error when insufficient params are passed" do
      expect { router.url(nil) }.to raise_error(Hanami::Router::InvalidRouteExpansionError, "No route could be generated for nil - please check given arguments")
    end
  end
end
