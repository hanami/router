# frozen_string_literal: true

require "hanami/router/formatter/csv"

RSpec.describe Hanami::Router::Formatter::CSV do
  let(:headers) { described_class::HEADERS.join(",") }

  describe "#call" do
    it "returns a CSV representation of the routes" do
      routes = [
        Hanami::Router::Route.new(http_method: "GET", path: "/resources/:id", to: "resource#show", as: :resource, constraints: {id: /\d+/})
      ]

      expected = "GET,/resources/:id,resource#show,:resource,id: /\\d+/"
      expect(subject.call(routes)).to eq("#{headers}\n#{expected}\n")
    end

    it "includes the headers by default" do
      expect(subject.call([])).to include(headers)
    end

    it "can provide generating options" do
      routes = [
        Hanami::Router::Route.new(http_method: "GET", path: "/", to: "home#index", as: :root, constraints: {})
      ]

      rendered_routes = subject.call(routes, col_sep: ";", write_headers: false)

      expected = "GET;/;home#index;:root;\"\"\n"
      expect(rendered_routes).to eq(expected)
    end

    it "doesn't include HEAD routes" do
      routes = [
        Hanami::Router::Route.new(http_method: "HEAD", path: "/resources/:id", to: "resource#show")
      ]

      expect(subject.call(routes)).not_to include("resource#show")
    end

    it "doesn't break when 'as' is not provided" do
      routes = [
        Hanami::Router::Route.new(http_method: "GET", path: "/resources/:id", to: "resource#show", constraints: {id: /\d+/})
      ]

      expect { subject.call(routes) }.not_to raise_error
    end

    it "doesn't break when 'constraints' is not provided" do
      routes = [
        Hanami::Router::Route.new(http_method: "GET", path: "/resources/:id", to: "resource#show", as: :resource)
      ]

      expect { subject.call(routes) }.not_to raise_error
    end
  end
end
