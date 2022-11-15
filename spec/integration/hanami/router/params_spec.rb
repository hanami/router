# frozen_string_literal: true

require "json"

RSpec.describe "Params" do
  subject do
    e = endpoint

    Hanami::Router.new do
      get "/search",  to: e
      post "/submit", to: e
      patch "/user/:id/update", to: e
    end
  end

  let(:endpoint) { ->(*) { [200, {}, ["OK"]] } }

  context "plain request" do
    it "has empty params on GET request" do
      env = Rack::MockRequest.env_for("/search")
      subject.call(env)

      expect(env["router.params"]).to eq({})
    end

    it "has empty params on POST request" do
      env = Rack::MockRequest.env_for("/submit", method: "POST")
      subject.call(env)

      expect(env["router.params"]).to eq({})
    end
  end

  context "query string" do
    it "has params from GET query string" do
      env = Rack::MockRequest.env_for("/search?q=hanami")
      subject.call(env)

      expect(env["router.params"]).to eq(q: "hanami")
    end
  end

  context "form payload" do
    it "has params from POST form submission" do
      input = {"preferences" => {"language" => "Ruby", "framework" => "Hanami", "popularity" => "100%"}}
      env = Rack::MockRequest.env_for("/submit", method: "POST", params: input)
      subject.call(env)

      expected = Hanami::Router::Params.deep_symbolize(input)
      expect(env["router.params"]).to eq(expected)
    end

    it "ignores missing 'rack.input'" do
      env = Rack::MockRequest.env_for("/submit", method: "POST")
      env.delete("rack.input")
      subject.call(env)

      expect(env["router.params"]).to eq({})
    end

    it "rewinds 'rack.input'" do
      input = {"foo" => 23}
      env = Rack::MockRequest.env_for("/submit", method: "POST", params: input)
      subject.call(env)

      expected = Rack::Utils.build_nested_query(input)
      expect(env["rack.input"].read).to eq(expected)
    end
  end

  context "json payload" do
    it "shouldn't parse a json payload" do
      input = JSON.generate("foo" => "100% bar")
      env = Rack::MockRequest.env_for("/submit", method: "POST", params: input)
      env["CONTENT_TYPE"] = "application/json"
      subject.call(env)
      
      expect(env["router.params"]).to eq({})
    end
  end

  context "file upload" do
    # TODO: test a file upload
  end

  context "priority" do
    it "gives first level priority to path variables" do
      expected = "23"
      env = Rack::MockRequest.env_for("/user/#{expected}/update?id=1", method: "PATCH", params: {id: 2})
      subject.call(env)

      expect(env["router.params"]).to eq(id: expected)
    end

    it "gives second level priority to query string variables" do
      expected = "23"
      env = Rack::MockRequest.env_for("/submit?id=#{expected}", method: "POST", params: {id: 2})
      subject.call(env)

      expect(env["router.params"]).to eq(id: expected)
    end
  end
end
