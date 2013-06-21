$:.unshift 'lib'
require 'benchmark'
require 'lotus/router'

# head -$((${RANDOM} % `wc -l < /usr/share/dict/words` + 1)) /usr/share/dict/words | tail -1

BATCH_SIZE = (ENV['BATCH_SIZE'] || 1000  ).to_i
TIMES      = (ENV['TIMES']      || 100000).to_i

dict       = File.readlines('/usr/share/dict/words').each {|l| l.chomp! }.uniq
$routes, $named_routes, $callable, $resource, $resources, _ = *dict.each_slice(BATCH_SIZE).to_a

$router    = Lotus::Router.new
$app       = Rack::MockRequest.new($router)
$endpoint  = ->(env) { [200, {}, ['']] }

puts "Loading #{ BATCH_SIZE } routes, calling for #{ TIMES } times...\n"

class ResourceController
  class Action
    def call(env)
      [200, {}, ['']]
    end
  end
  class New     < Action; end
  class Create  < Action; end
  class Show    < Action; end
  class Edit    < Action; end
  class Update  < Action; end
  class Destroy < Action; end
end

class ResourcesController < ResourceController
  class Index < Action; end
end

$named_routes = $named_routes.map do |r|
  [r, r.to_sym]
end

$resource.each do |w|
  eval "#{ Lotus::Utils::String.titleize(w) }Controller = Class.new(ResourceController)"
end

$resources.each do |w|
  eval "#{ Lotus::Utils::String.titleize(w) }Controller = Class.new(ResourcesController)"
end

GC.start
