# frozen_string_literal: true

RSpec.describe Hanami::Router do
  let(:app) { Rack::MockRequest.new(router) }

  describe "#resources" do
    let(:router) do
      described_class.new do
        resources "flowers"
      end
    end

    it "recognizes get index" do
      expect(router.path(:flowers)).to eq("/flowers")
      expect(app.request("GET", "/flowers", lint: true).body).to eq("Flowers::Index")
    end

    it "recognizes get new" do
      expect(router.path(:new_flower)).to eq("/flowers/new")
      expect(app.request("GET", "/flowers/new", lint: true).body).to eq("Flowers::New")
    end

    it "recognizes post create" do
      expect(router.path(:flowers)).to eq("/flowers")
      expect(app.request("POST", "/flowers", lint: true).body).to eq("Flowers::Create")
    end

    it "recognizes get show" do
      expect(router.path(:flower, id: 23)).to eq("/flowers/23")
      expect(app.request("GET", "/flowers/23", lint: true).body).to eq("Flowers::Show 23")
    end

    it "recognizes get edit" do
      expect(router.path(:edit_flower, id: 23)).to eq("/flowers/23/edit")
      expect(app.request("GET", "/flowers/23/edit", lint: true).body).to eq("Flowers::Edit 23")
    end

    it "recognizes patch update" do
      expect(router.path(:flower, id: 23)).to eq("/flowers/23")
      expect(app.request("PATCH", "/flowers/23", lint: true).body).to eq("Flowers::Update 23")
    end

    it "recognizes delete destroy" do
      expect(router.path(:flower, id: 23)).to eq("/flowers/23")
      expect(app.request("DELETE", "/flowers/23", lint: true).body).to eq("Flowers::Destroy 23")
    end

    context ":only option" do
      let(:router) do
        described_class.new do
          resources "keyboards", only: %i[index edit]
        end
      end

      it "recognizes only specified paths" do
        expect(router.path(:keyboards)).to eq("/keyboards")
        expect(app.request("GET", "/keyboards", lint: true).body).to eq("Keyboards::Index")

        expect(router.path(:edit_keyboard, id: 23)).to eq("/keyboards/23/edit")
        expect(app.request("GET", "/keyboards/23/edit", lint: true).body).to eq("Keyboards::Edit 23")
      end

      it "does not recognize other paths" do
        expect(app.request("GET",    "/keyboards/new", lint: true).status).to eq(404)
        expect(app.request("POST",   "/keyboards", lint: true).status).to eq(405)
        expect(app.request("GET",    "/keyboards/23", lint: true).status).to eq(404)
        expect(app.request("PATCH",  "/keyboards/23", lint: true).status).to eq(404)
        expect(app.request("DELETE", "/keyboards/23", lint: true).status).to eq(404)

        expect { router.path(:new_keyboards) }.to raise_error(Hanami::Routing::InvalidRouteException, "No route could be generated for :new_keyboards - please check given arguments")
      end
    end

    context ":except option" do
      let(:router) do
        described_class.new do
          resources "keyboards", except: %i[new show update destroy]
        end
      end

      it "recognizes only the non-rejected paths" do
        expect(router.path(:keyboards)).to eq("/keyboards")
        expect(app.request("GET", "/keyboards", lint: true).body).to eq("Keyboards::Index")

        expect(router.path(:edit_keyboard, id: 23)).to eq("/keyboards/23/edit")
        expect(app.request("GET", "/keyboards/23/edit", lint: true).body).to eq("Keyboards::Edit 23")

        expect(router.path(:keyboards)).to eq("/keyboards")
        expect(app.request("POST", "/keyboards", lint: true).body).to eq("Keyboards::Create")
      end

      it "does not recognize other paths" do
        expect(app.request("GET",    "/keyboards/new", lint: true).status).to eq(404)
        expect(app.request("PATCH",  "/keyboards/23", lint: true).status).to eq(404)
        expect(app.request("DELETE", "/keyboards/23", lint: true).status).to eq(404)

        expect { router.path(:new_keyboards) }.to raise_error(Hanami::Routing::InvalidRouteException, "No route could be generated for :new_keyboards - please check given arguments")
      end
    end

    context "member" do
      let(:router) do
        described_class.new do
          resources "keyboards", only: [:show] do
            member do
              get "screenshot"
              get "/print"
            end
          end
        end
      end

      it "recognizes the path" do
        expect(router.path(:screenshot_keyboard, id: 23)).to eq("/keyboards/23/screenshot")
        expect(app.request("GET", "/keyboards/23/screenshot", lint: true).body).to eq("Keyboards::Screenshot 23")
      end

      it "recognizes the path with a leading slash" do
        expect(router.path(:print_keyboard, id: 23)).to eq("/keyboards/23/print")
        expect(app.request("GET", "/keyboards/23/print", lint: true).body).to eq("Keyboards::Print 23")
      end
    end

    context "collection" do
      let(:router) do
        described_class.new do
          resources "keyboards", only: [:show] do
            collection do
              get "search"
              get "/characters"
            end
          end
        end
      end

      it "recognizes the path" do
        expect(router.path(:search_keyboards)).to eq("/keyboards/search")
        expect(app.request("GET", "/keyboards/search", lint: true).body).to eq("Keyboards::Search")
      end

      it "recognizes the path with a leading slash" do
        expect(router.path(:characters_keyboards)).to eq("/keyboards/characters")
        expect(app.request("GET", "/keyboards/characters", lint: true).body).to eq("Keyboards::Characters")
      end
    end

    context ":controller option" do
      let(:router) do
        described_class.new do
          resources "keyboards", controller: "keys" do
            collection do
              get "search"
            end

            member do
              get "screenshot"
            end
          end
        end
      end

      it "recognizes path with different controller" do
        expect(router.path(:keyboards)).to eq("/keyboards")
        expect(router.path(:keyboard, id: 3)).to eq("/keyboards/3")
        expect(router.path(:new_keyboard)).to eq("/keyboards/new")
        expect(router.path(:edit_keyboard, id: 5)).to eq("/keyboards/5/edit")
        expect(router.path(:search_keyboards)).to eq("/keyboards/search")
        expect(router.path(:screenshot_keyboard, id: 8)).to eq("/keyboards/8/screenshot")

        expect(app.request("GET", "/keyboards", lint: true).body).to eq("Keys::Index")
        expect(app.request("GET", "/keyboards/new", lint: true).body).to eq("Keys::New")
        expect(app.request("GET", "/keyboards/1/edit", lint: true).body).to eq("Keys::Edit 1")
        expect(app.request("POST", "/keyboards", lint: true).body).to eq("Keys::Create")
        expect(app.request("PATCH", "/keyboards/1", lint: true).body).to eq("Keys::Update 1")
        expect(app.request("DELETE", "/keyboards/1", lint: true).body).to eq("Keys::Destroy 1")
        expect(app.request("GET", "/keyboards/search", lint: true).body).to eq("Keys::Search")
        expect(app.request("GET", "/keyboards/8/screenshot", lint: true).body).to eq("Keys::Screenshot 8")
      end
    end

    context ":as option" do
      let(:router) do
        described_class.new do
          resources "keyboards", as: "pianos" do
            collection do
              get "search"
            end

            member do
              get "screenshot"
            end
          end
        end
      end

      it "recognizes the new name" do
        expect(router.path(:pianos)).to eq("/keyboards")
        expect(router.path(:piano, id: 3)).to eq("/keyboards/3")
        expect(router.path(:new_piano)).to eq("/keyboards/new")
        expect(router.path(:edit_piano, id: 5)).to eq("/keyboards/5/edit")
        expect(router.path(:search_pianos)).to eq("/keyboards/search")
        expect(router.path(:screenshot_piano, id: 8)).to eq("/keyboards/8/screenshot")
      end

      it "does not recognize the resource name" do
        e = Hanami::Routing::InvalidRouteException
        expect { router.path(:keyboards) }.to raise_error(e)
        expect { router.path(:keyboard, id: 3) }.to raise_error(e)
        expect { router.path(:new_keyboard) }.to raise_error(e)
        expect { router.path(:edit_keyboard, id: 5) }.to raise_error(e)
        expect { router.path(:search_keyboards) }.to raise_error(e)
        expect { router.path(:screenshot_keyboard, id: 8) }.to raise_error(e)
      end
    end
  end
end
