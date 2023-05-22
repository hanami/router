RSpec.describe Hanami::Router do
  describe "context option" do
    let(:app) { Rack::MockRequest.new(router) }

    let(:router) { described_class.new(context: context, &routes) }

    let(:routes) do
      proc do |context|
        mount lambda { |_|
          [200, {}, ["context says #{context.greeting}"]]
        }, at: "/test"
      end
    end

    let(:context) { double(:context, greeting: "hello world") }

    # FIXME: Ask Tim if this is still needed
    xit "is available as a routing block argument" do
      expect(app.request("GET", "/test").body).to eq("context says hello world")
    end
  end
end
