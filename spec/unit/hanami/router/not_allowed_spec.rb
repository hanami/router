# frozen_string_literal: true

RSpec.describe Hanami::Router do
  subject do
    described_class.new do
      get "/", to: ->(*) { [200, {"Content-Length" => "4"}, ["root"]] }
    end
  end

  describe "Not Allowed" do
    it "it returns 405 when an endpoint can be found but the request uses the wrong HTTP verb" do
      env = Rack::MockRequest.env_for("/", method: :post)
      status, headers, body = subject.call(env)

      expect(status).to  eq(405)
      expect(headers).to eq("Content-Length" => "18")
      expect(body).to    eq(["Method Not Allowed"])
    end

    it "doesn't cache previous 405 header responses" do
      router = subject
      app = Rack::Builder.new do
        use RandomMiddleware
        run router
      end.to_app

      # first request
      request("/", app, :post)

      # second request
      request("/", app, :post)
    end

    private

    def request(path, app, http_method = :get)
      env = Rack::MockRequest.env_for(path, method: http_method)
      status, headers, body = app.call(env)

      random_headers_count = RandomMiddleware.headers_count(headers)
      expect(status).to               eq(405)
      expect(random_headers_count).to be(1)
      expect(body).to                 eq(["Method Not Allowed"])
    end
  end
end
