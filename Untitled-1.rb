require "roda"

class App < Roda
  plugin :all_verbs
  plugin :not_allowed

  route do |r|
    r.get "user" do
      "get user"
    end
    # r.on "user" do
    #   r.get do
    #     "get user"
    #   end
    # end
  end
end

Rack::Server.start app: App.freeze.app, Port: 2300


require 'http_router'

router = HttpRouter.new
# router.add('/user/').name(:my_test_path).to {|env| [200, {}, "Hey dude #{env['router.params'][:variable]}"]}
router.get('/user').to {|env| [200, {}, ["get /user"]]}

Rack::Server.start app: router, Port: 2300