RSpec.describe Hanami::Router::Route do
  describe "#inspect_to" do
    context "when it's a String" do
      it "returns it unmodified" do
        route = Hanami::Router::Route.new(http_method: "GET", path: "/", to: "/")

        expect(route.inspect_to).to eq("/")
      end
    end

    context "when it's a Proc" do
      it "returns (proc)" do
        route = Hanami::Router::Route.new(http_method: "GET", path: "/", to: -> { "/" })

        expect(route.inspect_to).to eq("(proc)")
      end
    end

    context "when it's a Class" do
      it "returns (class) when it's anonymous" do
        route = Hanami::Router::Route.new(http_method: "GET", path: "/", to: Class.new)

        expect(route.inspect_to).to eq("(class)")
      end

      it "returns the class name when it's named" do
        route = Hanami::Router::Route.new(http_method: "GET", path: "/", to: described_class)

        expect(route.inspect_to).to eq("Hanami::Router::Route")
      end
    end

    context "when it's a Hanami::Router::Block" do
      it "returns (block)" do
        route = Hanami::Router::Route.new(http_method: "GET", path: "/", to: Hanami::Router::Block.new(-> {}, :development))

        expect(route.inspect_to).to eq("(block)")
      end
    end

    context "when it's a Hanami::Router::Redirect" do
      it "returns formatted destination and HTTP code" do
        route = Hanami::Router::Route.new(http_method: "GET", path: "/", to: Hanami::Router::Redirect.new("redirect", 301, "/"))

        expect(route.inspect_to).to eq("redirect (HTTP 301)")
      end
    end

    context "when it's an instance" do
      it "returns (class) when its class is anonymous" do
        route = Hanami::Router::Route.new(http_method: "GET", path: "/", to: Class.new.new)

        expect(route.inspect_to).to eq("(class)")
      end

      it "returns its class name when its class is named" do
        route = Hanami::Router::Route.new(http_method: "GET", path: "/", to: Object.new)

        expect(route.inspect_to).to eq("Object")
      end
    end
  end

  context "#inspect_constraints" do
    it "returns empty string when there are no constraints" do
      route = Hanami::Router::Route.new(http_method: "GET", path: "/", to: "/")

      expect(route.inspect_constraints).to eq("")
    end

    it "returns formatted constraints when there're some" do
      route = Hanami::Router::Route.new(http_method: "GET", path: "/", to: "/", constraints: {id: /\d+/})

      expect(route.inspect_constraints).to eq("id: /\\d+/")
    end
  end

  context "#inspect_as" do
    it "returns empty string when there's no as" do
      route = Hanami::Router::Route.new(http_method: "GET", path: "/", to: "/")

      expect(route.inspect_as).to eq("")
    end

    it "returns as string when there's an as" do
      route = Hanami::Router::Route.new(http_method: "GET", path: "/", to: "/", as: :root)

      expect(route.inspect_as).to eq(":root")
    end
  end
end
