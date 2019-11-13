RSpec.describe Hanami::Router do
  describe "context option" do
    let(:app) { Rack::MockRequest.new(router) }

    let(:router) { described_class.new(context: context, &routes) }

    let(:routes) {
      proc do |context|
        mount -> _ {
          [200, {}, ["context says #{context.greeting}"]]
        }, at: "/test"
      end
    }

    let(:context) { double(:context, greeting: "hello world") }

    it "is available as a routing block argument" do
      expect(app.request("GET", "/test").body).to eq("context says hello world")
    end
  end
end
