# frozen_string_literal: true

require "hanami/router/monitoring"
require "rack/request"

RSpec.describe Hanami::Router do
  subject do
    described_class.new(monitoring: Hanami::Router::Monitoring.new) do
      root { "Hello" }
    end
  end

  let(:listener) do
    Class.new do
      attr_reader :events

      def initialize
        @events = []
      end

      def on_hanami_monitoring_router_lookup(event)
        @events << event
      end
    end.new
  end

  it "monitors routes lookup and dispatch" do
    subject.monitoring.subscribe(listener)

    env = Rack::MockRequest.env_for("/", method: :get)
    response = subject.call(env)

    expect(response[0]).to be(200)
    expect(response[2]).to eq(["Hello"])

    expect(listener.events.count).to be(1) # lookup

    event = listener.events[0]
    expect(event.id).to eq(Hanami::Router::Monitoring::KEY)
    expect(event.payload.keys).to match_array([:elapsed])
  end
end
