# frozen_string_literal: true

require "rack/mock"

RSpec.describe Hanami::Router do
  describe "block" do
    subject do
      described_class.new do
        get "/greeting" do
          "hello"
        end

        get "/status" do
          status 201
        end

        get "/headers" do
          headers["X-Custom-Header"] = "OK"
        end

        get "/books/:id" do
          "book #{params[:id]}"
        end
      end
    end

    it "returns body" do
      env = Rack::MockRequest.env_for("/greeting")
      status, _, body = subject.call(env)

      expect(status).to eq(200)
      expect(body).to eq(["hello"])
    end

    it "sets status" do
      env = Rack::MockRequest.env_for("/status")
      status, = subject.call(env)

      expect(status).to eq(201)
    end

    it "sets headers" do
      env = Rack::MockRequest.env_for("/headers")
      _, headers, = subject.call(env)

      expect(headers.fetch("X-Custom-Header")).to eq("OK")
    end

    it "yields req that includes params" do
      env = Rack::MockRequest.env_for("/books/23")
      status, _, body = subject.call(env)

      expect(status).to eq(200)
      expect(body).to eq(["book 23"])
    end
  end
end
