# frozen_string_literal: true

RSpec.describe Hanami::Router do
  describe "with prefix option" do
    let(:router) do
      e = endpoint
      Hanami::Router.new(base_url: base_url, prefix: prefix) do
        get     "/home", to: e, as: :get_home
        post    "/home", to: e, as: :post_home
        put     "/home", to: e, as: :put_home
        patch   "/home", to: e, as: :patch_home
        delete  "/home", to: e, as: :delete_home
        trace   "/home", to: e, as: :trace_home
        options "/home", to: e, as: :options_home

        get  "/admin",      to: e, as: :get_admin
        get  "/admin/new",  to: e, as: :new_admin
        get  "/admin/edit", to: e, as: :edit_admin
        post "/admin",      to: e, as: :create_admin
        put  "/admin",      to: e, as: :put_admin

        scope :dashboard do
          get "/home", to: ->(*) {}, as: :home
        end
      end
    end
    let(:base_url) { "https://hanami.test" }
    let(:prefix) { "/admin" }
    let(:endpoint) { ->(*) { [200, {"Content-Length" => "4"}, ["home"]] } }

    it "generates relative URLs with prefix" do
      expect(router.path(:get_home)).to eq("/admin/home")
      expect(router.path(:post_home)).to eq("/admin/home")
      expect(router.path(:put_home)).to eq("/admin/home")
      expect(router.path(:patch_home)).to eq("/admin/home")
      expect(router.path(:delete_home)).to eq("/admin/home")
      expect(router.path(:trace_home)).to eq("/admin/home")
      expect(router.path(:options_home)).to eq("/admin/home")

      expect(router.path(:get_admin)).to eq("/admin/admin")
      expect(router.path(:new_admin)).to eq("/admin/admin/new")
      expect(router.path(:create_admin)).to eq("/admin/admin")
      expect(router.path(:edit_admin)).to eq("/admin/admin/edit")
      expect(router.path(:put_admin)).to eq("/admin/admin")

      expect(router.path(:dashboard_home)).to eq("/admin/dashboard/home")
    end

    it "generates absolute URLs with prefix" do
      expect(router.url(:get_home)).to eq("https://hanami.test/admin/home")
      expect(router.url(:post_home)).to eq("https://hanami.test/admin/home")
      expect(router.url(:put_home)).to eq("https://hanami.test/admin/home")
      expect(router.url(:patch_home)).to eq("https://hanami.test/admin/home")
      expect(router.url(:delete_home)).to eq("https://hanami.test/admin/home")
      expect(router.url(:trace_home)).to eq("https://hanami.test/admin/home")
      expect(router.url(:options_home)).to eq("https://hanami.test/admin/home")

      expect(router.url(:dashboard_home)).to eq("https://hanami.test/admin/dashboard/home")
    end

    %w[GET POST PUT PATCH DELETE TRACE OPTIONS].each do |verb|
      it "recognizes requests (#{verb})" do
        env = Rack::MockRequest.env_for("/admin/home", method: verb)
        status, _, body = router.call(env)

        expect(status).to eq(200)
        expect(body).to eq(["home"])
      end
    end

    it "redirect works with prefix" do
      router = Hanami::Router.new(prefix: prefix) do
        redirect "/redirect", to: "/redirect_destination"
        get "/redirect_destination", to: ->(*) { [200, {}, ["Redirect destination!"]] }
      end

      env = Rack::MockRequest.env_for("/admin/redirect")
      status, headers, = router.call(env)

      expect(status).to eq(301)
      expect(headers["location"]).to eq("/admin/redirect_destination")
    end
  end
end
