# frozen_string_literal: true

RSpec.describe Hanami::Router do
  describe "#prefix" do
    let(:app) { Rack::MockRequest.new(router) }
    let(:configuration) { Action::Configuration.new("prefix") }

    it "recognizes get path" do
      router = described_class.new do
        prefix "trees" do
          get "/plane-tree", to: ->(_) { [200, {}, ["Trees (GET)!"]] }
        end
      end

      app = Rack::MockRequest.new(router)

      expect(app.request("GET", "/trees/plane-tree", lint: true).body).to eq("Trees (GET)!")
    end

    it "recognizes post path" do
      router = described_class.new do
        prefix "trees" do
          post "/sequoia", to: ->(_) { [200, {}, ["Trees (POST)!"]] }
        end
      end

      app = Rack::MockRequest.new(router)

      expect(app.request("POST", "/trees/sequoia", lint: true).body).to eq("Trees (POST)!")
    end

    it "recognizes put path" do
      router = described_class.new do
        prefix "trees" do
          put "/cherry-tree", to: ->(_) { [200, {}, ["Trees (PUT)!"]] }
        end
      end

      app = Rack::MockRequest.new(router)

      expect(app.request("PUT", "/trees/cherry-tree", lint: true).body).to eq("Trees (PUT)!")
    end

    it "recognizes patch path" do
      router = described_class.new do
        prefix "trees" do
          patch "/cedar", to: ->(_) { [200, {}, ["Trees (PATCH)!"]] }
        end
      end

      app = Rack::MockRequest.new(router)

      expect(app.request("PATCH", "/trees/cedar", lint: true).body).to eq("Trees (PATCH)!")
    end

    it "recognizes delete path" do
      router = described_class.new do
        prefix "trees" do
          delete "/pine", to: ->(_) { [200, {}, ["Trees (DELETE)!"]] }
        end
      end

      app = Rack::MockRequest.new(router)

      expect(app.request("DELETE", "/trees/pine", lint: true).body).to eq("Trees (DELETE)!")
    end

    it "recognizes trace path" do
      router = described_class.new do
        prefix "trees" do
          trace "/cypress", to: ->(_) { [200, {}, ["Trees (TRACE)!"]] }
        end
      end

      app = Rack::MockRequest.new(router)

      expect(app.request("TRACE", "/trees/cypress", lint: true).body).to eq("Trees (TRACE)!")
    end

    it "recognizes options path" do
      router = described_class.new do
        prefix "trees" do
          options "/oak", to: ->(_) { [200, {}, ["Trees (OPTIONS)!"]] }
        end
      end

      app = Rack::MockRequest.new(router)

      expect(app.request("OPTIONS", "/trees/oak", lint: true).body).to eq("Trees (OPTIONS)!")
    end

    context "nested" do
      it "defines HTTP methods correctly" do
        router = described_class.new do
          prefix "animals" do
            prefix "mammals" do
              get "/cats", to: ->(_) { [200, {}, ["Meow!"]] }
            end
          end
        end

        app = Rack::MockRequest.new(router)

        expect(app.request("GET", "/animals/mammals/cats", lint: true).body).to eq("Meow!")
      end

      it "defines #resource correctly" do
        router = described_class.new(configuration: configuration) do
          prefix "users" do
            prefix "management" do
              resource "avatar"
            end
          end
        end

        app = Rack::MockRequest.new(router)

        expect(app.request("GET", "/users/management/avatar", lint: true).body).to eq("Avatar::Show")
        expect(router.path(:users_management_avatar)).to eq("/users/management/avatar")
      end

      it "defines #resources correctly" do
        router = described_class.new(configuration: configuration) do
          prefix "vegetals" do
            prefix "pretty" do
              resources "flowers"
            end
          end
        end

        app = Rack::MockRequest.new(router)

        expect(app.request("GET", "/vegetals/pretty/flowers", lint: true).body).to eq("Flowers::Index")
        expect(router.path(:vegetals_pretty_flowers)).to eq("/vegetals/pretty/flowers")
      end

      it "defines #redirect correctly" do
        router = described_class.new do
          prefix "users" do
            prefix "settings" do
              redirect "/image", to: "/avatar"
            end
          end
        end

        app = Rack::MockRequest.new(router)

        expect(app.request("GET", "users/settings/image", lint: true).headers["Location"]).to eq("/users/settings/avatar")
      end
    end

    context "redirect" do
      let(:router) do
        described_class.new do
          prefix "users" do
            get "/home", to: ->(_) { [200, {}, ["New Home!"]] }
            redirect "/dashboard", to: "/home"
          end
        end
      end

      it "recognizes get path" do
        expect(app.request("GET", "/users/dashboard", lint: true).headers["Location"]).to eq("/users/home")
        expect(app.request("GET", "/users/dashboard", lint: true).status).to eq(301)
      end
    end

    context "restful resources" do
      let(:router) do
        described_class.new(configuration: configuration) do
          prefix "vegetals" do
            resources "flowers"
          end
        end
      end

      it "recognizes get index" do
        expect(router.path(:vegetals_flowers)).to eq("/vegetals/flowers")
        expect(app.request("GET", "/vegetals/flowers", lint: true).body).to eq("Flowers::Index")
      end

      it "recognizes get new" do
        expect(router.path(:new_vegetals_flower)).to eq("/vegetals/flowers/new")
        expect(app.request("GET", "/vegetals/flowers/new", lint: true).body).to eq("Flowers::New")
      end

      it "recognizes post create" do
        expect(router.path(:vegetals_flowers)).to eq("/vegetals/flowers")
        expect(app.request("POST", "/vegetals/flowers", lint: true).body).to eq("Flowers::Create")
      end

      it "recognizes get show" do
        expect(router.path(:vegetals_flower, id: 23)).to eq("/vegetals/flowers/23")
        expect(app.request("GET", "/vegetals/flowers/23", lint: true).body).to eq("Flowers::Show 23")
      end

      it "recognizes get edit" do
        expect(router.path(:edit_vegetals_flower, id: 23)).to eq("/vegetals/flowers/23/edit")
        expect(app.request("GET", "/vegetals/flowers/23/edit", lint: true).body).to eq("Flowers::Edit 23")
      end

      it "recognizes patch update" do
        expect(router.path(:vegetals_flower, id: 23)).to eq("/vegetals/flowers/23")
        expect(app.request("PATCH", "/vegetals/flowers/23", lint: true).body).to eq("Flowers::Update 23")
      end

      it "recognizes delete destroy" do
        expect(router.path(:vegetals_flower, id: 23)).to eq("/vegetals/flowers/23")
        expect(app.request("DELETE", "/vegetals/flowers/23", lint: true).body).to eq("Flowers::Destroy 23")
      end

      context ":only option" do
        let(:router) do
          described_class.new(configuration: configuration) do
            prefix "electronics" do
              resources "keyboards", only: %i[index edit]
            end
          end
        end

        it "recognizes only specified paths" do
          expect(router.path(:electronics_keyboards)).to eq("/electronics/keyboards")
          expect(app.request("GET", "/electronics/keyboards", lint: true).body).to eq("Keyboards::Index")

          expect(router.path(:edit_electronics_keyboard, id: 23)).to eq("/electronics/keyboards/23/edit")
          expect(app.request("GET", "/electronics/keyboards/23/edit", lint: true).body).to eq("Keyboards::Edit 23")
        end

        it "does not recognize other paths" do
          expect(app.request("GET",    "/electronics/keyboards/new", lint: true).status).to eq(404)
          expect(app.request("POST",   "/electronics/keyboards", lint: true).status).to eq(405)
          expect(app.request("GET",    "/electronics/keyboards/23", lint: true).status).to eq(404)
          expect(app.request("PATCH",  "/electronics/keyboards/23", lint: true).status).to eq(404)
          expect(app.request("DELETE", "/electronics/keyboards/23", lint: true).status).to eq(404)

          expect { router.path(:new_electronics_keyboards) }.to raise_error(Hanami::Routing::InvalidRouteException, "No route could be generated for :new_electronics_keyboards - please check given arguments")
        end
      end

      context ":except option" do
        let(:router) do
          described_class.new(configuration: configuration) do
            prefix "electronics" do
              resources "keyboards", except: %i[new show update destroy]
            end
          end
        end

        it "recognizes only the non-rejected paths" do
          expect(router.path(:electronics_keyboards)).to eq("/electronics/keyboards")
          expect(app.request("GET", "/electronics/keyboards", lint: true).body).to eq("Keyboards::Index")

          expect(router.path(:edit_electronics_keyboard, id: 23)).to eq("/electronics/keyboards/23/edit")
          expect(app.request("GET", "/electronics/keyboards/23/edit", lint: true).body).to eq("Keyboards::Edit 23")

          expect(router.path(:electronics_keyboards)).to eq("/electronics/keyboards")
          expect(app.request("POST", "/electronics/keyboards", lint: true).body).to eq("Keyboards::Create")
        end

        it "does not recognize other paths" do
          expect(app.request("GET",    "/electronics/keyboards/new", lint: true).status).to eq(404)
          expect(app.request("PATCH",  "/electronics/keyboards/23", lint: true).status).to eq(404)
          expect(app.request("DELETE", "/electronics/keyboards/23", lint: true).status).to eq(404)

          expect { router.path(:new_electronics_keyboards) }.to raise_error(Hanami::Routing::InvalidRouteException, "No route could be generated for :new_electronics_keyboards - please check given arguments")
        end
      end

      context "additional actions" do
        let(:router) do
          described_class.new(configuration: configuration) do
            prefix "electronics" do
              resources "keyboards" do
                collection { get "search" }
                member     { get "screenshot" }
              end
            end
          end
        end

        it "recognizes collection actions" do
          expect(router.path(:search_electronics_keyboards)).to eq("/electronics/keyboards/search")
          expect(app.request("GET", "/electronics/keyboards/search", lint: true).body).to eq("Keyboards::Search")
        end

        it "recognizes member actions" do
          expect(router.path(:screenshot_electronics_keyboard, id: 23)).to eq("/electronics/keyboards/23/screenshot")
          expect(app.request("GET", "/electronics/keyboards/23/screenshot", lint: true).body).to eq("Keyboards::Screenshot 23")
        end
      end
    end

    context "named RESTful resources" do
      let(:router) do
        described_class.new(configuration: configuration) do
          prefix "vegetals" do
            resources "flowers", as: "tulips"
          end
        end
      end

      it "recognizes get index" do
        expect(router.path(:vegetals_tulips)).to eq("/vegetals/flowers")
        expect(app.request("GET", "/vegetals/flowers", lint: true).body).to eq("Flowers::Index")
      end

      it "recognizes get new" do
        expect(router.path(:new_vegetals_tulip)).to eq("/vegetals/flowers/new")
        expect(app.request("GET", "/vegetals/flowers/new", lint: true).body).to eq("Flowers::New")
      end

      it "recognizes post create" do
        expect(router.path(:vegetals_tulips)).to eq("/vegetals/flowers")
        expect(app.request("POST", "/vegetals/flowers", lint: true).body).to eq("Flowers::Create")
      end

      it "recognizes get show" do
        expect(router.path(:vegetals_tulip, id: 23)).to eq("/vegetals/flowers/23")
        expect(app.request("GET", "/vegetals/flowers/23", lint: true).body).to eq("Flowers::Show 23")
      end

      it "recognizes get edit" do
        expect(router.path(:edit_vegetals_tulip, id: 23)).to eq("/vegetals/flowers/23/edit")
        expect(app.request("GET", "/vegetals/flowers/23/edit", lint: true).body).to eq("Flowers::Edit 23")
      end

      it "recognizes patch update" do
        expect(router.path(:vegetals_tulip, id: 23)).to eq("/vegetals/flowers/23")
        expect(app.request("PATCH", "/vegetals/flowers/23", lint: true).body).to eq("Flowers::Update 23")
      end

      it "recognizes delete destroy" do
        expect(router.path(:vegetals_tulip, id: 23)).to eq("/vegetals/flowers/23")
        expect(app.request("DELETE", "/vegetals/flowers/23", lint: true).body).to eq("Flowers::Destroy 23")
      end
    end

    context "restful resource" do
      let(:router) do
        described_class.new(configuration: configuration) do
          prefix "settings" do
            resource "avatar"
          end
        end
      end

      it "recognizes get new" do
        expect(router.path(:new_settings_avatar)).to eq("/settings/avatar/new")
        expect(app.request("GET", "/settings/avatar/new", lint: true).body).to eq("Avatar::New")
      end

      it "recognizes post create" do
        expect(router.path(:settings_avatar)).to eq("/settings/avatar")
        expect(app.request("POST", "/settings/avatar", lint: true).body).to eq("Avatar::Create")
      end

      it "recognizes get show" do
        expect(router.path(:settings_avatar)).to eq("/settings/avatar")
        expect(app.request("GET", "/settings/avatar", lint: true).body).to eq("Avatar::Show")
      end

      it "recognizes get edit" do
        expect(router.path(:edit_settings_avatar)).to eq("/settings/avatar/edit")
        expect(app.request("GET", "/settings/avatar/edit", lint: true).body).to eq("Avatar::Edit")
      end

      it "recognizes patch update" do
        expect(router.path(:settings_avatar)).to eq("/settings/avatar")
        expect(app.request("PATCH", "/settings/avatar", lint: true).body).to eq("Avatar::Update")
      end

      it "recognizes delete destroy" do
        expect(router.path(:settings_avatar)).to eq("/settings/avatar")
        expect(app.request("DELETE", "/settings/avatar", lint: true).body).to eq("Avatar::Destroy")
      end

      context ":only option" do
        let(:router) do
          described_class.new(configuration: configuration) do
            prefix "settings" do
              resource "profile", only: %i[edit update]
            end
          end
        end

        it "recognizes only specified paths" do
          expect(router.path(:edit_settings_profile)).to eq("/settings/profile/edit")
          expect(app.request("GET", "/settings/profile/edit", lint: true).body).to eq("Profile::Edit")

          expect(router.path(:settings_profile)).to eq("/settings/profile")
          expect(app.request("PATCH", "/settings/profile", lint: true).body).to eq("Profile::Update")
        end

        it "does not recognize other paths" do
          expect(app.request("GET",    "/settings/profile", lint: true).status).to eq(405)
          expect(app.request("GET",    "/settings/profile/new", lint: true).status).to eq(404)
          expect(app.request("POST",   "/settings/profile", lint: true).status).to eq(405)
          expect(app.request("DELETE", "/settings/profile", lint: true).status).to eq(405)

          expect { router.path(:new_settings_profile) }.to raise_error(Hanami::Routing::InvalidRouteException, "No route could be generated for :new_settings_profile - please check given arguments")
        end
      end

      context ":except option" do
        let(:router) do
          described_class.new(configuration: configuration) do
            prefix "settings" do
              resource "profile", except: %i[edit update]
            end
          end
        end

        it "recognizes only the non-rejected paths" do
          expect(router.path(:settings_profile)).to eq("/settings/profile")
          expect(app.request("GET", "/settings/profile", lint: true).body).to eq("Profile::Show")

          expect(router.path(:new_settings_profile)).to eq("/settings/profile/new")
          expect(app.request("GET", "/settings/profile/new", lint: true).body).to eq("Profile::New")

          expect(router.path(:settings_profile)).to eq("/settings/profile")
          expect(app.request("POST", "/settings/profile", lint: true).body).to eq("Profile::Create")

          expect(router.path(:settings_profile)).to eq("/settings/profile")
          expect(app.request("DELETE", "/settings/profile", lint: true).body).to eq("Profile::Destroy")
        end

        it "does not recognize other paths" do
          expect(app.request("GET", "/settings/profile/edit", lint: true).status).to eq(404)

          expect { router.path(:edit_settings_profile) }.to raise_error(Hanami::Routing::InvalidRouteException, "No route could be generated for :edit_settings_profile - please check given arguments")
        end
      end
    end

    context "named RESTful resource" do
      let(:router) do
        described_class.new(configuration: configuration) do
          prefix "settings" do
            resource "avatar", as: "icon"
          end
        end
      end

      it "recognizes get new" do
        expect(router.path(:new_settings_icon)).to eq("/settings/avatar/new")
        expect(app.request("GET", "/settings/avatar/new", lint: true).body).to eq("Avatar::New")
      end

      it "recognizes post create" do
        expect(router.path(:settings_icon)).to eq("/settings/avatar")
        expect(app.request("POST", "/settings/avatar", lint: true).body).to eq("Avatar::Create")
      end

      it "recognizes get show" do
        expect(router.path(:settings_icon)).to eq("/settings/avatar")
        expect(app.request("GET", "/settings/avatar", lint: true).body).to eq("Avatar::Show")
      end

      it "recognizes get edit" do
        expect(router.path(:edit_settings_icon)).to eq("/settings/avatar/edit")
        expect(app.request("GET", "/settings/avatar/edit", lint: true).body).to eq("Avatar::Edit")
      end

      it "recognizes patch update" do
        expect(router.path(:settings_icon)).to eq("/settings/avatar")
        expect(app.request("PATCH", "/settings/avatar", lint: true).body).to eq("Avatar::Update")
      end

      it "recognizes delete destroy" do
        expect(router.path(:settings_icon)).to eq("/settings/avatar")
        expect(app.request("DELETE", "/settings/avatar", lint: true).body).to eq("Avatar::Destroy")
      end
    end

    describe "mount" do
      let(:router) do
        described_class.new do
          prefix "api" do
            mount Backend::App, at: "/backend"
          end
        end
      end

      RSpec::Support::HTTP.verbs.each do |verb|
        it "accepts #{verb} for a prefixed mount" do
          expect(app.request(verb.upcase, "/api/backend", lint: true).body).to eq(body_for("home", verb))
        end
      end
    end
  end
end
