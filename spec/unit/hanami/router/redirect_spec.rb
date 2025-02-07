# frozen_string_literal: true

RSpec.describe Hanami::Router do
  describe "#redirect" do
    it "recognizes string endpoint" do
      endpoint = ->(_env) { [200, {}, ["Redirect destination!"]] }
      router   = Hanami::Router.new do
        get "/redirect_destination", to: endpoint, as: :destination
        redirect "/redirect", to: "/redirect_destination"
      end

      env = Rack::MockRequest.env_for("/redirect")
      status, headers, = router.call(env)

      location_header = if Hanami::Router.modern_rack?
                          headers.fetch("location")
                        else
                          headers["Location"]
                        end

      expect(status).to eq(301)
      expect(location_header).to eq("/redirect_destination")
    end

    it "recognizes string endpoint with custom http code" do
      endpoint = ->(_env) { [200, {}, ["Redirect destination!"]] }
      router   = Hanami::Router.new do
        get "/redirect_destination", to: endpoint
        redirect "/redirect", to: "/redirect_destination", code: 302
      end

      env = Rack::MockRequest.env_for("/redirect")
      status, headers, = router.call(env)

      location_header = if Hanami::Router.modern_rack?
                          headers.fetch("location")
                        else
                          headers["Location"]
                        end

      expect(status).to eq(302)
      expect(location_header).to eq("/redirect_destination")
    end
  end
end
