# frozen_string_literal: true

require "json"

RSpec.describe Hanami::Router do
  subject do
    described_class.new do
      get "/", to: ->(*) {}
      post "/books", to: ->(*) {}
      put   "/login", to: ->(*) {}
      patch "/login", to: ->(*) {}

      get "/books/:id", to: ->(*) {}
      post "/books/:id/comments", to: ->(*) {}
      put   "/books/:book_id/comments/:id", to: ->(*) {}
      patch "/books/:book_id/comments/:id", to: ->(*) {}
    end
  end

  describe "Not Allowed" do
    context "fixed path" do
      it "it returns 405" do
        env = Rack::MockRequest.env_for("/", method: :post)
        status, headers, body = subject.call(env)

        expect(status).to  eq(405)
        expect(headers).to eq(RSpec::Support::HTTP.headers("Content-Length" => "18", "Allow" => "GET, HEAD"))
        expect(body).to    eq(["Method Not Allowed"])
      end

      context "with single HTTP verb" do
        it "it returns 405" do
          env = Rack::MockRequest.env_for("/books", method: :options)
          status, headers, body = subject.call(env)

          expect(status).to  eq(405)
          expect(headers).to eq(RSpec::Support::HTTP.headers("Content-Length" => "18", "Allow" => "POST"))
          expect(body).to    eq(["Method Not Allowed"])
        end
      end

      context "with multiple HTTP verbs" do
        it "it returns 405" do
          env = Rack::MockRequest.env_for("/login", method: :delete)
          status, headers, body = subject.call(env)

          expect(status).to  eq(405)
          expect(headers).to eq(RSpec::Support::HTTP.headers("Content-Length" => "18", "Allow" => "PUT, PATCH"))
          expect(body).to    eq(["Method Not Allowed"])
        end
      end
    end

    context "variable path" do
      it "it returns 405" do
        env = Rack::MockRequest.env_for("/books/23", method: :post)
        status, headers, body = subject.call(env)

        expect(status).to  eq(405)
        expect(headers).to eq(RSpec::Support::HTTP.headers("Content-Length" => "18", "Allow" => "GET, HEAD"))
        expect(body).to    eq(["Method Not Allowed"])
      end

      context "with single HTTP verb" do
        it "it returns 405" do
          env = Rack::MockRequest.env_for("/books/23/comments", method: :options)
          status, headers, body = subject.call(env)

          expect(status).to  eq(405)
          expect(headers).to eq(RSpec::Support::HTTP.headers("Content-Length" => "18", "Allow" => "POST"))
          expect(body).to    eq(["Method Not Allowed"])
        end
      end

      context "with multiple HTTP verbs" do
        it "it returns 405" do
          env = Rack::MockRequest.env_for("/books/23/comments/99", method: :delete)
          status, headers, body = subject.call(env)

          expect(status).to  eq(405)
          expect(headers).to eq(RSpec::Support::HTTP.headers("Content-Length" => "18", "Allow" => "PUT, PATCH"))
          expect(body).to    eq(["Method Not Allowed"])
        end
      end
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

    context "with not_allowed option" do
      let(:not_allowed) {
        ->(*, allowed_http_methods) {
          [499, RSpec::Support::HTTP.headers({"Content-Type" => "application/json"}), [JSON.dump(allowed: allowed_http_methods)]]
        }
      }

      subject {
        described_class.new(not_allowed: not_allowed) do
          get "/", to: ->(*) {}
        end
      }

      it "uses it" do
        env = Rack::MockRequest.env_for("/", method: :post)
        status, headers, body = subject.call(env)

        expect(status).to eq(499)
        expect(headers).to eq(RSpec::Support::HTTP.headers("Content-Type" => "application/json"))
        expect(body).to eq(['{"allowed":["GET","HEAD"]}'])
      end
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
