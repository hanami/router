# frozen_string_literal: true

RSpec.describe Hanami::Router do
  let(:router) do
    e = endpoint
    Hanami::Router.new(scheme: "https", host: "test.com", port: 443) do
      get "/hanami",               to: e, as: :fixed
      get "/flowers/:id",          to: e, as: :variables
      get "/books/:id", id: /\d+/, to: e, as: :constraints
      get "/articles(.:format)",   to: e, as: :optional
      get "/files/*glob",          to: e, as: :glob
      resources :leaves,                  as: :resources
      resource :stem,                     as: :singular_resource
    end
  end

  let(:endpoint) { ->(_) { [200, {}, ["Hi!"]] } }

  describe "#path" do
    it "recognizes fixed string" do
      expect(router.path(:fixed)).to eq("/hanami")
    end

    it "recognizes string with variables" do
      expect(router.path(:variables, id: "hanami")).to eq("/flowers/hanami")
    end

    it "raises error when variables aren't satisfied" do
      expect { router.path(:variables) }.to raise_error(Hanami::Routing::InvalidRouteException, "cannot expand with keys [], possible expansions: [:id]")
    end

    it "recognizes string with variables and constraints" do
      expect(router.path(:constraints, id: 23)).to eq("/books/23")
    end

    it "recognizes optional variables" do
      expect(router.path(:optional)).to eq("/articles")
      expect(router.path(:optional, page: "1")).to eq("/articles?page=1")
      expect(router.path(:optional, format: "rss")).to eq("/articles.rss")
      expect(router.path(:optional, format: "rss", page: "1")).to eq("/articles.rss?page=1")
    end

    it "recognizes glob string" do
      expect(router.path(:glob)).to eq("/files/")
    end

    it "escapes additional params in query string" do
      expect(router.path(:fixed, return_to: "/dashboard")).to eq("/hanami?return_to=%2Fdashboard")
    end

    it "raises error when insufficient params are passed" do
      expect { router.path(nil) }.to raise_error(Hanami::Routing::InvalidRouteException, "No route could be generated for nil - please check given arguments")
    end

    describe "plural resource routes" do
      it "recognizes index" do
        expect(router.path(:resources)).to eq("/leaves")
      end

      it "recognizes new" do
        expect(router.path(:new_resource)).to eq("/leaves/new")
      end

      it "recognizes edit" do
        expect(router.path(:edit_resource, id: 1)).to eq("/leaves/1/edit")
      end

      it "recognizes show" do
        expect(router.path(:resource, id: 1)).to eq("/leaves/1")
      end
    end

    describe "singular resource routes" do
      it "recognizes new" do
        expect(router.path(:new_singular_resource)).to eq("/stem/new")
      end

      it "recognizes edit" do
        expect(router.path(:edit_singular_resource)).to eq("/stem/edit")
      end

      it "recognizes show" do
        expect(router.path(:singular_resource)).to eq("/stem")
      end
    end
  end
end
