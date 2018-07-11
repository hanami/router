require 'rexml/document'
require 'hanami/routing/parsing/parser'
require 'hanami/middleware/body_parser'

module Web
  module Controllers
    module Home
      class Index
        # mocking class call method for middleware
        def self.call(env)
          code, headers, body = self.new.call(env)
          [code, headers.merge('X-Middleware' => 'CALLED'), body]
        end

        def call(params)
          [200, {}, ['Hello from Web::Controllers::Home::Index']]
        end
      end
    end # Home

    module Dashboard
      class Index
        def call(params)
          [200, {}, ['Hello from Web::Controllers::Dashboard::Index']]
        end
      end
    end # Dashboard
  end
end # Web

module Front
  class App
    def call(env)
      case env['PATH_INFO']
      when '/home'
        [200, {}, ['front']]
      else
        [404, {}, ['Not Found']]
      end
    end
  end
end # Front

module Back
  class App
    def call(env)
      case env['PATH_INFO']
      when '/home'
        [200, {}, ['back']]
      else
        [404, {}, ['Not Found']]
      end
    end
  end
end # Back

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
    VERBS = %w[GET POST DELETE PUT PATCH TRACE OPTIONS LINK UNLINK]
    def self.call(env)
      if VERBS.include? env['REQUEST_METHOD']
        [200, {}, ['home']]
      else
        [405, {}, ['Method Not Allowed']]
      end
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

module Keys
  class Index
    def call(env)
      [200, {}, ['Keys::Index']]
    end
  end

  class New
    def call(env)
      [200, {}, ['Keys::New']]
    end
  end

  class Create
    def call(env)
      [200, {}, ['Keys::Create']]
    end
  end

  class Edit
    def call(env)
      [200, {}, ['Keys::Edit ' + env['router.params'][:id]]]
    end
  end

  class Update
    def call(env)
      [200, {}, ['Keys::Update ' + env['router.params'][:id]]]
    end
  end

  class Show
    def call(env)
      [200, {}, ['Keys::Show ' + env['router.params'][:id]]]
    end
  end

  class Destroy
    def call(env)
      [200, {}, ['Keys::Destroy ' + env['router.params'][:id]]]
    end
  end

  class Search
    def call(env)
      [200, {}, ['Keys::Search']]
    end
  end

  class Screenshot
    def call(env)
      [200, {}, ['Keys::Screenshot ' + env['router.params'][:id]]]
    end
  end
end # Keyboards

class XmlMiddelwareParser < Hanami::Middleware::Parsing::Parser
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

class XmlParser < Hanami::Routing::Parsing::Parser
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
    [200, {}, ['RackMiddleware']]
  end
end

class RackMiddlewareInstanceMethod
  def call(env)
    [200, {}, ['RackMiddlewareInstanceMethod']]
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

module Nested
  module Controllers
    module Users
      module Posts
        class Index
          def call(env)
            [200, {}, ['Hello from Nested::Controllers::Users::Posts::Index']]
          end
        end
      end
      module Avatar
        class Show
          def call(env)
            [200, {}, ['Hello from Nested::Controllers::Users::Avatar::Show']]
          end
        end
      end
      module Posts
        module Comments
          class Index
            def call(env)
              [200, {}, ['Hello from Nested::Controllers::Users::Posts::Comments::Index']]
            end
          end
        end
      end
    end
    module User
      module Comments
        class Index
          def call(env)
            [200, {}, ['Hello from Nested::Controllers::User::Comments::Index']]
          end
        end
      end
      module ApiKey
        class Show
          def call(env)
            [200, {}, ['Hello from Nested::Controllers::User::ApiKey::Show']]
          end
        end
      end
    end
    module Products
      module Variants
        class Index
          def call(env)
            [200, {}, ['Hello from Nested::Controllers::Products::Variants::Index']]
          end
        end
        class Show
          def call(env)
            [200, {}, ['Hello from Nested::Controllers::Products::Variants::Show']]
          end
        end
      end
    end
  end
end

# NESTED

# resource > resource > resource
module User
  class New
    def call(env)
      [200, {}, ['User::New']]
    end
  end

  class Create
    def call(env)
      [200, {}, ['User::Create']]
    end
  end

  class Show
    def call(env)
      [200, {}, ['User::Show']]
    end
  end

  class Edit
    def call(env)
      [200, {}, ['User::Edit']]
    end
  end

  class Update
    def call(env)
      [200, {}, ['User::Update']]
    end
  end

  class Destroy
    def call(env)
      [200, {}, ['User::Destroy']]
    end
  end
  module Post
    class New
      def call(env)
        [200, {}, ['User::Post::New']]
      end
    end

    class Create
      def call(env)
        [200, {}, ['User::Post::Create']]
      end
    end

    class Show
      def call(env)
        [200, {}, ['User::Post::Show']]
      end
    end

    class Edit
      def call(env)
        [200, {}, ['User::Post::Edit']]
      end
    end

    class Update
      def call(env)
        [200, {}, ['User::Post::Update']]
      end
    end

    class Destroy
      def call(env)
        [200, {}, ['User::Post::Destroy']]
      end
    end
    module Comment
      class New
        def call(env)
          [200, {}, ['User::Post::Comment::New']]
        end
      end

      class Create
        def call(env)
          [200, {}, ['User::Post::Comment::Create']]
        end
      end

      class Show
        def call(env)
          [200, {}, ['User::Post::Comment::Show']]
        end
      end

      class Edit
        def call(env)
          [200, {}, ['User::Post::Comment::Edit']]
        end
      end

      class Update
        def call(env)
          [200, {}, ['User::Post::Comment::Update']]
        end
      end

      class Destroy
        def call(env)
          [200, {}, ['User::Post::Comment::Destroy']]
        end
      end
    end
  end
end

# resource > resource > resources
module User
  module Post
    module Comments
      class Index
        def call(env)
          [200, {}, ['User::Post::Comments::Index']]
        end
      end

      class New
        def call(env)
          [200, {}, ['User::Post::Comments::New']]
        end
      end

      class Create
        def call(env)
          [200, {}, ['User::Post::Comments::Create']]
        end
      end

      class Show
        def call(env)
          [200, {}, ['User::Post::Comments::Show']]
        end
      end

      class Edit
        def call(env)
          [200, {}, ['User::Post::Comments::Edit']]
        end
      end

      class Update
        def call(env)
          [200, {}, ['User::Post::Comments::Update']]
        end
      end

      class Destroy
        def call(env)
          [200, {}, ['User::Post::Comments::Destroy']]
        end
      end
    end
  end
end

# resource > resources > resources
module User
  module Posts
    class Index
      def call(env)
        [200, {}, ['User::Posts::Index']]
      end
    end

    class New
      def call(env)
        [200, {}, ['User::Posts::New']]
      end
    end

    class Create
      def call(env)
        [200, {}, ['User::Posts::Create']]
      end
    end

    class Show
      def call(env)
        [200, {}, ['User::Posts::Show']]
      end
    end

    class Edit
      def call(env)
        [200, {}, ['User::Posts::Edit']]
      end
    end

    class Update
      def call(env)
        [200, {}, ['User::Posts::Update']]
      end
    end

    class Destroy
      def call(env)
        [200, {}, ['User::Posts::Destroy']]
      end
    end

    module Comments
      class Index
        def call(env)
          [200, {}, ['User::Posts::Comments::Index']]
        end
      end

      class New
        def call(env)
          [200, {}, ['User::Posts::Comments::New']]
        end
      end

      class Create
        def call(env)
          [200, {}, ['User::Posts::Comments::Create']]
        end
      end

      class Show
        def call(env)
          [200, {}, ['User::Posts::Comments::Show']]
        end
      end

      class Edit
        def call(env)
          [200, {}, ['User::Posts::Comments::Edit']]
        end
      end

      class Update
        def call(env)
          [200, {}, ['User::Posts::Comments::Update']]
        end
      end

      class Destroy
        def call(env)
          [200, {}, ['User::Posts::Comments::Destroy']]
        end
      end
    end
  end
end

# resource > resources > resource
module User
  module Posts
    module Comment
      class New
        def call(env)
          [200, {}, ['User::Posts::Comment::New']]
        end
      end

      class Create
        def call(env)
          [200, {}, ['User::Posts::Comment::Create']]
        end
      end

      class Show
        def call(env)
          [200, {}, ['User::Posts::Comment::Show']]
        end
      end

      class Edit
        def call(env)
          [200, {}, ['User::Posts::Comment::Edit']]
        end
      end

      class Update
        def call(env)
          [200, {}, ['User::Posts::Comment::Update']]
        end
      end

      class Destroy
        def call(env)
          [200, {}, ['User::Posts::Comment::Destroy']]
        end
      end
    end
  end
end

# resources > resources > resources
module Users
  class Index
    def call(env)
      [200, {}, ['Users::Index']]
    end
  end

  class New
    def call(env)
      [200, {}, ['Users::New']]
    end
  end

  class Create
    def call(env)
      [200, {}, ['Users::Create']]
    end
  end

  class Show
    def call(env)
      [200, {}, ['Users::Show']]
    end
  end

  class Edit
    def call(env)
      [200, {}, ['Users::Edit']]
    end
  end

  class Update
    def call(env)
      [200, {}, ['Users::Update']]
    end
  end

  class Destroy
    def call(env)
      [200, {}, ['Users::Destroy']]
    end
  end

  module Posts
    class Index
      def call(env)
        [200, {}, ['Users::Posts::Index']]
      end
    end

    class New
      def call(env)
        [200, {}, ['Users::Posts::New']]
      end
    end

    class Create
      def call(env)
        [200, {}, ['Users::Posts::Create']]
      end
    end

    class Show
      def call(env)
        [200, {}, ['Users::Posts::Show']]
      end
    end

    class Edit
      def call(env)
        [200, {}, ['Users::Posts::Edit']]
      end
    end

    class Update
      def call(env)
        [200, {}, ['Users::Posts::Update']]
      end
    end

    class Destroy
      def call(env)
        [200, {}, ['Users::Posts::Destroy']]
      end
    end

    module Comments
      class Index
        def call(env)
          [200, {}, ['Users::Posts::Comments::Index']]
        end
      end

      class New
        def call(env)
          [200, {}, ['Users::Posts::Comments::New']]
        end
      end

      class Create
        def call(env)
          [200, {}, ['Users::Posts::Comments::Create']]
        end
      end

      class Show
        def call(env)
          [200, {}, ['Users::Posts::Comments::Show']]
        end
      end

      class Edit
        def call(env)
          [200, {}, ['Users::Posts::Comments::Edit']]
        end
      end

      class Update
        def call(env)
          [200, {}, ['Users::Posts::Comments::Update']]
        end
      end

      class Destroy
        def call(env)
          [200, {}, ['Users::Posts::Comments::Destroy']]
        end
      end
    end
  end
end # User

# resources > resources > resource
module Users
  module Posts
    module Comment
      class New
        def call(env)
          [200, {}, ['Users::Posts::Comment::New']]
        end
      end

      class Create
        def call(env)
          [200, {}, ['Users::Posts::Comment::Create']]
        end
      end

      class Show
        def call(env)
          [200, {}, ['Users::Posts::Comment::Show']]
        end
      end

      class Edit
        def call(env)
          [200, {}, ['Users::Posts::Comment::Edit']]
        end
      end

      class Update
        def call(env)
          [200, {}, ['Users::Posts::Comment::Update']]
        end
      end

      class Destroy
        def call(env)
          [200, {}, ['Users::Posts::Comment::Destroy']]
        end
      end
    end
  end
end

# resources > resource > resources
module Users
  module Post
    class New
      def call(env)
        [200, {}, ['Users::Post::New']]
      end
    end

    class Create
      def call(env)
        [200, {}, ['Users::Post::Create']]
      end
    end

    class Show
      def call(env)
        [200, {}, ['Users::Post::Show']]
      end
    end

    class Edit
      def call(env)
        [200, {}, ['Users::Post::Edit']]
      end
    end

    class Update
      def call(env)
        [200, {}, ['Users::Post::Update']]
      end
    end

    class Destroy
      def call(env)
        [200, {}, ['Users::Post::Destroy']]
      end
    end

    class Search
      def call(env)
        [200, {}, ['Users::Post::Search']]
      end
    end

    class Screenshot
      def call(env)
        [200, {}, ['Users::Post::Screenshot']]
      end
    end
    module Comments
      class Index
        def call(env)
          [200, {}, ['Users::Post::Comments::Index']]
        end
      end

      class New
        def call(env)
          [200, {}, ['Users::Post::Comments::New']]
        end
      end

      class Create
        def call(env)
          [200, {}, ['Users::Post::Comments::Create']]
        end
      end

      class Show
        def call(env)
          [200, {}, ['Users::Post::Comments::Show']]
        end
      end

      class Edit
        def call(env)
          [200, {}, ['Users::Post::Comments::Edit']]
        end
      end

      class Update
        def call(env)
          [200, {}, ['Users::Post::Comments::Update']]
        end
      end

      class Destroy
        def call(env)
          [200, {}, ['Users::Post::Comments::Destroy']]
        end
      end

      class Search
        def call(env)
          [200, {}, ['Users::Post::Comments::Search']]
        end
      end

      class Screenshot
        def call(env)
          [200, {}, ['Users::Post::Comments::Screenshot']]
        end
      end
    end
  end
end

# resources > resource > resource
module Users
  module Post
    module Comment
      class New
        def call(env)
          [200, {}, ['Users::Post::Comment::New']]
        end
      end

      class Create
        def call(env)
          [200, {}, ['Users::Post::Comment::Create']]
        end
      end

      class Show
        def call(env)
          [200, {}, ['Users::Post::Comment::Show']]
        end
      end

      class Edit
        def call(env)
          [200, {}, ['Users::Post::Comment::Edit']]
        end
      end

      class Update
        def call(env)
          [200, {}, ['Users::Post::Comment::Update']]
        end
      end

      class Destroy
        def call(env)
          [200, {}, ['Users::Post::Comment::Destroy']]
        end
      end
    end
  end
end
