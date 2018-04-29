# frozen_string_literal: true

require "rack/head"

RSpec.describe Hanami::Router do
  describe "#scope" do
    let(:app) { Rack::MockRequest.new(router) }
    let(:router) do
      described_class.new do
        scope "/admin", namespace: Admin::Controllers, configuration: Action::Configuration.new("admin") do
          root to: "home#index"

          get  "/signin", to: "sessions#new", as: :signin
          post "/signin", to: "sessions#create"

          resource  :settings, only: [:show]
          resources :users,    only: [:show]

          prefix "/t" do
            get "/:name", to: "topics#show"
          end

          redirect "/dashboard", to: "/"
          mount Backend::App, at: "/backend"
        end

        scope "/", namespace: Web::Controllers, configuration: Action::Configuration.new("web") do
          root to: "home#index"

          get  "/signin", to: "sessions#new", as: :signin
          post "/signin", to: "sessions#create"

          resource  :settings, only: [:show]
          resources :users,    only: [:show]

          prefix "/t" do
            get "/:name", to: "topics#show"
          end

          redirect "/dashboard", to: "/"
          mount Backend::App, at: "/backend"
        end
      end
    end

    it "recognizes root path" do
      expect(app.request("GET", "/", lint: true).body).to include("Web::Controllers::Home::Index")
      expect(app.request("GET", "/admin", lint: true).body).to include("Admin::Controllers::Home::Index")
    end

    it "recognizes get path" do
      expect(app.request("GET", "/signin", lint: true).body).to include("Web::Controllers::Sessions::New")
      expect(app.request("GET", "/admin/signin", lint: true).body).to include("Admin::Controllers::Sessions::New")
    end

    it "recognizes post path" do
      expect(app.request("POST", "/signin", lint: true).body).to include("Web::Controllers::Sessions::Create")
      expect(app.request("POST", "/admin/signin", lint: true).body).to include("Admin::Controllers::Sessions::Create")
    end

    it "recognizes resource" do
      expect(app.request("GET", "/settings", lint: true).body).to include("Web::Controllers::Settings::Show")
      expect(app.request("GET", "/admin/settings", lint: true).body).to include("Admin::Controllers::Settings::Show")
    end

    it "recognizes resources" do
      expect(app.request("GET", "/users/23", lint: true).body).to include("Web::Controllers::Users::Show")
      expect(app.request("GET", "/admin/users/23", lint: true).body).to include("Admin::Controllers::Users::Show")
    end

    it "recognizes prefixed actions" do
      expect(app.request("GET", "/t/ruby", lint: true).body).to include("Web::Controllers::Topics::Show")
      expect(app.request("GET", "/admin/t/ruby", lint: true).body).to include("Admin::Controllers::Topics::Show")
    end

    it "defines redirect" do
      expect(app.request("GET", "/dashboard", lint: true).headers["Location"]).to eq("/")
      expect(app.request("GET", "/admin/dashboard", lint: true).headers["Location"]).to eq("/admin")
    end

    context "mount" do
      RSpec::Support::HTTP.mountable_verbs.each do |verb|
        it "accepts #{verb} for a mounted app" do
          expect(app.request(verb.upcase, "/backend", lint: true).body).to eq(body_for("home", verb))
          expect(app.request(verb.upcase, "/admin/backend", lint: true).body).to eq(body_for("home", verb))
        end
      end

      context "HEAD" do
        let(:app) { Rack::MockRequest.new(Rack::Head.new(router)) }

        it "accepts head for mounted app" do
          expect(app.request("HEAD", "/backend", lint: true).body).to eq(body_for("home", "head"))
          expect(app.request("HEAD", "/admin/backend", lint: true).body).to eq(body_for("home", "head"))
        end
      end
    end

    context "named paths" do
      it "recognizes root path" do
        expect(router.path(:root)).to eq("/")
        expect(router.path(:admin_root)).to eq("/admin")
      end

      it "recognizes custom named path" do
        expect(router.path(:signin)).to eq("/signin")
        expect(router.path(:admin_signin)).to eq("/admin/signin")
      end

      it "recognizes resource" do
        expect(router.path(:setting)).to eq("/settings")
        expect(router.path(:admin_setting)).to eq("/admin/settings")
      end

      it "recognizes resources" do
        expect(router.path(:user, id: 23)).to eq("/users/23")
        expect(router.path(:admin_user, id: 23)).to eq("/admin/users/23")
      end

      xit "recognizes prefixed paths" do
        expect(router.path(:topic, name: "ruby")).to eq("/t/ruby")
        expect(router.path(:admin_topic, id: "ruby")).to eq("/admin/t/ruby")
      end
    end
  end
end
