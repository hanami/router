# frozen_string_literal: true

RSpec.describe Hanami::Router do
  subject { described_class.new {} }

  describe "Not Found" do
    it "it returns 404 when an endpoint cannot be found" do
      env = Rack::MockRequest.env_for("/")
      status, headers, body = subject.call(env)

      expect(status).to  eq(404)
      expect(headers).to eq("Content-Length" => "9")
      expect(body).to    eq(["Not Found"])
    end

    it "doesn't cache previous 404 header responses" do
      router = subject
      app = Rack::Builder.new do
        use RandomMiddleware
        run router
      end.to_app

      # first request
      request("/", app)

      # second request
      request("/", app)
    end

    context "with default_app option" do
      let(:not_found) { ->(_env) { [499, { "Content-Type" => "application/json" }, [JSON.dump({ error: "not_found" })]] } }
      subject { described_class.new(not_found: not_found) {} }

      it "uses it" do
        env = Rack::MockRequest.env_for("/")
        status, headers, body = subject.call(env)

        expect(status).to eq(499)
        expect(headers).to eq("Content-Type" => "application/json")
        expect(body).to eq(['{"error":"not_found"}'])
      end
    end

    private

    def request(path, app, http_method = :get)
      env = Rack::MockRequest.env_for(path, method: http_method)
      status, headers, body = app.call(env)

      random_headers_count = RandomMiddleware.headers_count(headers)
      expect(status).to               eq(404)
      expect(random_headers_count).to be(1)
      expect(body).to                 eq(["Not Found"])
    end
  end
end
