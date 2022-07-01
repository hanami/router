# frozen_string_literal: true

RSpec.describe Hanami::Router do
  before do
    unless defined?(Endpoint)
      class Endpoint
        def call(env)
        end
      end
    end

    unless defined?(App)
      class App
        def call(env)
        end
      end
    end
  end

  after do
    Object.__send__(:remove_const, :Endpoint) if defined?(Endpoint)
    Object.__send__(:remove_const, :App) if defined?(App)
  end

  describe "inspect" do
    subject do
      described_class.new(inspector: Hanami::Router::Inspector.new) do
        # ROOT
        root to: "home#index"

        # HTTP METHODS
        get "/foo", to: "controller#action"
        post "/foo", to: "controller#action"
        patch "/foo", to: "controller#action"
        put "/foo", to: "controller#action"
        delete "/foo", to: "controller#action"
        trace "/foo", to: "controller#action"
        options "/foo", to: "controller#action"
        link "/foo", to: "controller#action"
        unlink "/foo", to: "controller#action"

        # NAMED ROUTES
        get "/login", to: "sessions#new", as: :login

        # CONSTRAINTS
        get "/constraints/:id/:keyword", to: "constraints#show", id: /\d+/, keyword: /\w+/

        # BLOCK
        get "/block" do
        end

        # ENDPOINT DUCK-TYPING
        get "/proc", to: ->(*) { [200, {}, ["OK"]] }
        get "/class", to: Endpoint
        get "/object", to: Endpoint.new
        get "/anonymous", to: Class.new {}
        get "/anonymous-object", to: Class.new {}.new

        # REDIRECT
        redirect "/redirect", to: "/redirect_destination"
        redirect "/redirect-temporary", to: "/redirect_destination", code: 302

        # SCOPE
        scope "/v1" do
          get "/users", to: ->(*) {}
        end

        # MOUNT
        mount App.new, at: "/app"
      end
    end

    it "returns inspectable routes" do
      expected = [
        "GET     /                             home#index                    as :root",
        "GET     /foo                          controller#action",
        "POST    /foo                          controller#action",
        "PATCH   /foo                          controller#action",
        "PUT     /foo                          controller#action",
        "DELETE  /foo                          controller#action",
        "TRACE   /foo                          controller#action",
        "OPTIONS /foo                          controller#action",
        "LINK    /foo                          controller#action",
        "UNLINK  /foo                          controller#action",
        "GET     /login                        sessions#new                  as :login",
        "GET     /constraints/:id/:keyword     constraints#show              (id: /\\d+/, keyword: /\\w+/)",
        "GET     /block                        (block)",
        "GET     /proc                         (proc)",
        "GET     /class                        Endpoint",
        "GET     /object                       Endpoint",
        "GET     /anonymous                    (class)",
        "GET     /anonymous-object             (class)",
        "GET     /redirect                     /redirect_destination (HTTP 301)",
        "GET     /redirect-temporary           /redirect_destination (HTTP 302)",
        "GET     /v1/users                     (proc)",
        "*       /app                          App"
      ]

      actual = subject.inspector.()
      expected.each do |route|
        expect(actual).to include(route)
      end
    end
  end
end
