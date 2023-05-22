RSpec.describe Hanami::Router do
  describe "usage with Rack::ShowExceptions" do
    let(:app) do
      router  = Hanami::Router.new { get "/", to: ->(*) { 1 / 0 } }
      builder = Rack::Builder.new
      builder.use Rack::ShowExceptions
      builder.run router

      Rack::MockRequest.new(builder)
    end

    it "shows textual exception stack trace by default" do
      response = app.get("/", lint: true)

      expect(response.status).to eq(500)
      expect(response.body).to match("ZeroDivisionError")
    end

    it "shows exceptions page (when requesting HTML)" do
      response = app.get("/", "HTTP_ACCEPT" => "text/html", lint: true)

      expect(response.status).to eq(500)
      expect(response.body).to match("<body>")
      expect(response.body).to match("ZeroDivisionError")
    end
  end
end
