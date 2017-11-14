RSpec.describe Hanami::Routing::Route do
  let(:endpoint) { ->(_) {} }

  describe "#initialize" do
    it "returns a frozen instance" do
      route = described_class.new("GET", "/", endpoint, {})

      expect(route).to be_kind_of(described_class)
      expect(route).to be_frozen
    end
  end

  describe "#call" do
    it "calls the endpoint by forwarding the given Rack env" do
      endpoint = lambda do |env|
        env["called"] = "true"
        [200, {}, ["Called"]]
      end

      route = described_class.new("GET", "/", endpoint, {})
      env   = { "PATH_INFO" => "/" }

      _, _, body = *route.call(env)

      expect(body).to eq(["Called"])
      expect(env.fetch("called")).to eq("true")
    end

    it "sets params in Rack env, by interpolating path variables with PATH_INFO" do
      endpoint = lambda do |env|
        [200, {}, [env['router.params'].inspect]]
      end

      route = described_class.new("GET", "/authors/:author_id/books/:id", endpoint, {})
      env   = { "PATH_INFO" => "/authors/1/books/2" }

      _, _, body = *route.call(env)

      expect(body).to eq([%({:author_id=>"1", :id=>"2"})])
    end

    it "it captures query string into params" do
      endpoint = lambda do |env|
        [200, {}, [env['router.params'].inspect]]
      end

      route = described_class.new("GET", "/authors", endpoint, {})
      env   = { "PATH_INFO" => "/authors", "QUERY_STRING" => "page=23" }

      _, _, body = *route.call(env)

      expect(body).to eq([%({:page=>"23"})])
    end
  end

  describe "#path" do
    let(:route) { described_class.new("GET", "/authors/:author_id/books/:id", endpoint, {}) }

    it "generates path from given args" do
      expect(route.path(author_id: 1, id: 2)).to eq("/authors/1/books/2")
    end

    it "appends extra args to the query string" do
      expect(route.path(author_id: 1, id: 2, page: 7, per_page: 30)).to eq("/authors/1/books/2?page=7&per_page=30")
    end

    it "raises error if not enough args are given" do
      expect { route.path({}) }.to raise_error(Hanami::Routing::InvalidRouteException, "cannot expand with keys [], possible expansions: [:author_id, :id]")
    end
  end

  describe "#match?" do
    it "returns true if both path and http verb match" do
      route = described_class.new("GET", "/books", endpoint, {})
      env   = { "PATH_INFO" => "/books", "REQUEST_METHOD" => "GET" }

      expect(route.match?(env)).to be(true)
    end

    it "returns false if path matches, but http verb doesn't" do
      route = described_class.new("GET", "/books", endpoint, {})
      env   = { "PATH_INFO" => "/books", "REQUEST_METHOD" => "PATCH" }

      expect(route.match?(env)).to be(false)
    end

    it "returns false if path doesn't match, but http verb does" do
      route = described_class.new("GET", "/books", endpoint, {})
      env   = { "PATH_INFO" => "/foo", "REQUEST_METHOD" => "GET" }

      expect(route.match?(env)).to be(nil)
    end

    it "enforces route constraints" do
      route = described_class.new("GET", "/books/:id", endpoint, id: /[[:digit:]]*/)

      env = { "PATH_INFO" => "/books/23", "REQUEST_METHOD" => "GET" }
      expect(route.match?(env)).to be(true)

      env = { "PATH_INFO" => "/books/foo", "REQUEST_METHOD" => "GET" }
      expect(route.match?(env)).to be(nil)
    end
  end

  describe "#match_path?" do
    it "returns true if both path matches" do
      route = described_class.new("GET", "/books", endpoint, {})
      env   = { "PATH_INFO" => "/books" }

      expect(route.match_path?(env)).to_not be(nil)
    end

    it "returns false if path doesn't match" do
      route = described_class.new("GET", "/books", endpoint, {})
      env   = { "PATH_INFO" => "/bar" }

      expect(route.match_path?(env)).to be(nil)
    end
  end
end
