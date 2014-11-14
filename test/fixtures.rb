require 'rexml/document'
require 'lotus/routing/parsing/parser'

module Api
  class App
    def call(env)
      case env['PATH_INFO']
      when '/'
        [200, {}, ['home']]
      when '/articles'
        [200, {}, ['articles']]
      else
        [404, {}, ['Not Found']]
      end
    end
  end
end # Api

module Backend
  class App
    def self.call(env)
      [200, {}, ['home']]
    end
  end
end # Backend

module Dashboard
  class Index
    def call(env)
      [200, {}, ['dashboard']]
    end
  end
end # Dashboard

class TestEndpoint
  def call(env)
    'Hi from TestEndpoint!'
  end
end # TestEndpoint

module Test
  class Show
    def call(env)
      'Hi from Test::Show!'
    end
  end
end # Test

class TestApp
  class TestEndpoint
    def call(env)
      'Hi from TestApp::TestEndpoint!'
    end
  end

  module Test2
    class Show
      def call(env)
        'Hi from TestApp::Test2::Show!'
      end
    end
  end
end # TestApp

module Controllers
  class Test
    class Show
      def call(env)
        'Hi from Controllers::Test::Show!'
      end
    end
  end
end

module Avatar
  class New
    def call(env)
      [200, {}, ['Avatar::New']]
    end
  end

  class Create
    def call(env)
      [200, {}, ['Avatar::Create']]
    end
  end

  class Show
    def call(env)
      [200, {}, ['Avatar::Show']]
    end
  end

  class Edit
    def call(env)
      [200, {}, ['Avatar::Edit']]
    end
  end

  class Update
    def call(env)
      [200, {}, ['Avatar::Update']]
    end
  end

  class Destroy
    def call(env)
      [200, {}, ['Avatar::Destroy']]
    end
  end
end # Avatar

module Profile
  class Show
    def call(env)
      [200, {}, ['Profile::Show']]
    end
  end

  class New
    def call(env)
      [200, {}, ['Profile::New']]
    end
  end

  class Create
    def call(env)
      [200, {}, ['Profile::Create']]
    end
  end

  class Edit
    def call(env)
      [200, {}, ['Profile::Edit']]
    end
  end

  class Update
    def call(env)
      [200, {}, ['Profile::Update']]
    end
  end

  class Destroy
    def call(env)
      [200, {}, ['Profile::Destroy']]
    end
  end

  class Activate
    def call(env)
      [200, {}, ['Profile::Activate']]
    end
  end

  class Deactivate
    def call(env)
      [200, {}, ['Profile::Deactivate']]
    end
  end

  class Keys
    def call(env)
      [200, {}, ['Profile::Keys']]
    end
  end

  class Activities
    def call(env)
      [200, {}, ['Profile::Activities']]
    end
  end
end # Profile

module Flowers
  class Index
    def call(env)
      [200, {}, ['Flowers::Index']]
    end
  end

  class New
    def call(env)
      [200, {}, ['Flowers::New']]
    end
  end

  class Create
    def call(env)
      [200, {}, ['Flowers::Create']]
    end
  end

  class Show
    def call(env)
      [200, {}, ['Flowers::Show ' + env['router.params'][:id]]]
    end
  end

  class Edit
    def call(env)
      [200, {}, ['Flowers::Edit ' + env['router.params'][:id]]]
    end
  end

  class Update
    def call(env)
      [200, {}, ['Flowers::Update ' + env['router.params'][:id]]]
    end
  end

  class Destroy
    def call(env)
      [200, {}, ['Flowers::Destroy ' + env['router.params'][:id]]]
    end
  end
end # Flowers

module Keyboards
  class Index
    def call(env)
      [200, {}, ['Keyboards::Index']]
    end
  end

  class Create
    def call(env)
      [200, {}, ['Keyboards::Create']]
    end
  end

  class Edit
    def call(env)
      [200, {}, ['Keyboards::Edit ' + env['router.params'][:id]]]
    end
  end

  class Show
    def call(env)
      [200, {}, ['Keyboards::Show ' + env['router.params'][:id]]]
    end
  end

  class Search
    def call(env)
      [200, {}, ['Keyboards::Search']]
    end
  end

  class Screenshot
    def call(env)
      [200, {}, ['Keyboards::Screenshot ' + env['router.params'][:id]]]
    end
  end

  class Print
    def call(env)
      [200, {}, ['Keyboards::Print ' + env['router.params'][:id]]]
    end
  end

  class Characters
    def call(env)
      [200, {}, ['Keyboards::Characters']]
    end
  end
end # Keyboards

class XmlParser < Lotus::Routing::Parsing::Parser
  def mime_types
    ['application/xml', 'text/xml']
  end

  def parse(body)
    result = {}

    xml = REXML::Document.new(body)
    xml.elements.each('*') {|el| result[el.name] = el.text }

    result
  end
end

class RackMiddleware
  def self.call(env)
  end
end

class RackMiddlewareInstanceMethod
  def call(env)
  end
end

module CreditCards
  class Index
    def call(env)
      [200, {}, ['Hello from CreditCards::Index']]
    end
  end
end

module Travels
  module Controllers
    module Journeys
      class Index
        def call(env)
          [200, {}, ['Hello from Travels::Controllers::Journeys::Index']]
        end
      end
    end
  end
end
