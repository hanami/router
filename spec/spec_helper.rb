$LOAD_PATH.unshift "lib"
require "hanami/utils"
require "hanami/devtools/unit"
require "hanami/router"
require "rack"

Rack::MockResponse.class_eval do
  def equal?(other)
    other = Rack::MockResponse.new(*other)

    status    == other.status  &&
      headers == other.headers &&
      body    == other.body
  end
end

Hanami::Utils.require!("spec/support")
