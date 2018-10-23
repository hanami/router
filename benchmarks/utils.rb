$:.unshift 'lib'
require 'benchmark'
require 'hanami/router'

# head -$((${RANDOM} % `wc -l < /usr/share/dict/words` + 1)) /usr/share/dict/words | tail -1

BATCH_SIZE = (ENV['BATCH_SIZE'] || 1000  ).to_i
TIMES      = (ENV['TIMES']      || 100000).to_i

dict       = File.readlines('/usr/share/dict/words').each {|l| l.chomp! }.uniq
$routes, $named_routes, $callable, $resource, $resources, $lazy, _ = *dict.each_slice(BATCH_SIZE).to_a

puts "Loading #{ BATCH_SIZE } routes, calling for #{ TIMES } times...\n"

class Controller
  def call(env)
    [200, {}, ['']]
  end
end

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

$endpoint             = ->(env) { [200, {}, ['']] }
$controller           = Controller
$resource_controller  = ResourceController
$resources_controller = ResourcesController

$named_routes = $named_routes.map do |r|
  [r, r.to_sym]
end

$resource.each do |w|
  eval "#{ Hanami::Utils::String.classify(w) }Controller = Class.new($resource_controller)"
end

$resources.each do |w|
  eval "#{ Hanami::Utils::String.classify(w) }Controller = Class.new($resources_controller)"
end

GC.start
