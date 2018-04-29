# frozen_string_literal: true

require "rack/head"

RSpec.describe Hanami::Router do
  shared_examples "mountable rack endpoint" do |verb|
    context "path recognition" do
      context "fixed string" do
        let(:response) { Rack::MockResponse.new(200, { "Content-Length" => "6" }, "Fixed!") }

        it "recognizes" do
          expect(app.request(verb.upcase, "/hanami", lint: true)).to be(response)
        end
      end

      context "moving parts string" do
        let(:response) { Rack::MockResponse.new(200, { "Content-Length" => "7" }, "Moving!") }

        it "recognizes" do
          expect(app.request(verb.upcase, "/hanami/23", lint: true)).to be(response)
        end
      end

      context "globbing string" do
        let(:response) { Rack::MockResponse.new(200, { "Content-Length" => "9" }, "Globbing!") }

        it "recognizes" do
          expect(app.request(verb.upcase, "/hanami/all", lint: true)).to be(response)
        end
      end

      context "format string" do
        let(:response) { Rack::MockResponse.new(200, { "Content-Length" => "7" }, "Format!") }

        it "recognizes" do
          expect(app.request(verb.upcase, "/hanami/all.json", lint: true)).to be(response)
        end
      end

      context "block" do
        let(:response) { Rack::MockResponse.new(200, { "Content-Length" => "6" }, "Block!") }

        it "recognizes" do
          expect(app.request(verb.upcase, "/block", lint: true)).to be(response)
        end
      end
    end

    describe "constraints" do
      let(:response) { Rack::MockResponse.new(200, { "Content-Length" => "24" }, "Moving with constraints!") }

      it "recognize when called with matching constraints" do
        expect(app.request(verb.upcase, "/books/23", lint: true)).to be(response)
        expect(app.request(verb.upcase, "/books/awdwror", lint: true).status).to eq(404)
      end
    end
  end

  shared_examples "mountable rack endpoint HEAD" do
    context "path recognition" do
      context "fixed string" do
        it "recognizes" do
          expect(app.request("HEAD", "/hanami", lint: true)).to be(response)
        end
      end

      context "moving parts string" do
        it "recognizes" do
          expect(app.request("HEAD", "/hanami/23", lint: true)).to be(response)
        end
      end

      context "globbing string" do
        it "recognizes" do
          expect(app.request("HEAD", "/hanami/all", lint: true)).to be(response)
        end
      end

      context "format string" do
        it "recognizes" do
          expect(app.request("HEAD", "/hanami/all.json", lint: true)).to be(response)
        end
      end

      context "block" do
        it "recognizes" do
          expect(app.request("HEAD", "/block", lint: true)).to be(response)
        end
      end
    end

    describe "constraints" do
      it "recognize when called with matching constraints" do
        expect(app.request("HEAD", "/books/23", lint: true)).to be(response)
        expect(app.request("HEAD", "/books/awdwror", lint: true).status).to eq(404)
      end
    end
  end

  RSpec::Support::HTTP.mountable_verbs.each do |verb|
    context "##{verb}" do
      let(:router) do
        r = response

        described_class.new do
          __send__ verb, "/hanami",               to: ->(_) { r }
          __send__ verb, "/hanami/:id",           to: ->(_) { r }
          __send__ verb, "/hanami/:id(.:format)", to: ->(_) { r }
          __send__ verb, "/hanami/*glob",         to: ->(_) { r }
          __send__ verb, "/books/:id",            to: ->(_) { r }, id: /\d+/
          __send__ verb, "/named_route",          to: ->(_) { r }, as: :"#{verb}_named_route"
          __send__ verb, "/named_:var",           to: ->(_) { r }, as: :"#{ verb }_named_route_var"
          __send__(verb, "/block")                          { |_| r }
        end
      end

      let(:app) { Rack::MockRequest.new(router) }

      it_behaves_like "mountable rack endpoint", verb

      context "named routes" do
        context "symbol" do
          let(:response) { Rack::MockResponse.new(200, { "Content-Length" => "12" }, "Named route!") }

          it "recognizes by the given symbol" do
            expect(router.path(:"#{ verb }_named_route")).to eq("/named_route")
            expect(router.url(:"#{ verb }_named_route")).to  eq("http://localhost/named_route")
          end
        end

        context "compiled variables" do
          let(:response) { Rack::MockResponse.new(200, { "Content-Length" => "13" }, "Named %route!") }

          it "recognizes" do
            expect(router.path(:"#{ verb }_named_route_var", var: "route")).to eq("/named_route")
            expect(router.url(:"#{ verb }_named_route_var", var: "route")).to  eq("http://localhost/named_route")
          end
        end

        context "custom url parts" do
          let(:response) { Rack::MockResponse.new(200, { "Content-Length" => "30" }, "Named route with custom parts!") }

          it "recognizes" do
            r      = response
            router = Hanami::Router.new(scheme: "https", host: "hanamirb.org", port: 443) do
              __send__ verb, "/custom_named_route", to: ->(_) { r }, as: :"#{verb}_custom_named_route"
            end

            expect(router.url(:"#{verb}_custom_named_route")).to eq("https://hanamirb.org/custom_named_route")
          end
        end
      end

      context "#HEAD" do
        let(:app) { Rack::MockRequest.new(Rack::Head.new(router)) }
        let(:response) { Rack::MockResponse.new(405, { "Content-Length" => "18" }, []) }

        it_behaves_like "mountable rack endpoint HEAD"
      end
    end
  end # main each

  describe "#root" do
    context "path recognition" do
      let(:app) { Rack::MockRequest.new(router) }

      context "fixed string" do
        let(:router) do
          r = response

          described_class.new do
            root to: ->(_) { r }
          end
        end

        let(:response) { Rack::MockResponse.new(200, { "Content-Length" => "6" }, "Fixed!") }

        it "recognizes" do
          actual = app.request("GET", "/", lint: true)

          expect(actual.status).to eq(response.status)
          expect(actual.header).to eq(response.header)
          expect(actual.body).to   eq(response.body)
        end

        it "recognizes by :root" do
          expect(router.path(:root)).to eq("/")
          expect(router.url(:root)).to  eq("http://localhost/")
        end
      end

      context "block" do
        let(:router) do
          r = response

          described_class.new do
            root { |_| r }
          end
        end

        let(:response) { Rack::MockResponse.new(200, { "Content-Length" => "6" }, "Block!") }

        it "recognizes" do
          actual = app.request("GET", "/", lint: true)

          expect(actual.status).to eq(response.status)
          expect(actual.header).to eq(response.header)
          expect(actual.body).to   eq(response.body)
        end
      end
    end
  end
end
