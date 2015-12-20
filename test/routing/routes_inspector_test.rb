require 'test_helper'
require 'lotus/routing/routes_inspector'

describe Lotus::Routing::RoutesInspector do
  describe '#to_s' do
    before do
      @path = ::File.expand_path(__FILE__)
    end

    describe 'named routes with procs' do
      before do
        @router = Lotus::Router.new do
          get '/login',  to: ->(env) { },       as: :login
          get '/logout', to: Proc.new {|env| }, as: :logout
        end
      end

      it 'inspects routes' do
        expectations = [
          %( login GET, HEAD  /login                         #<Proc@#{ @path }:13 (lambda)>),
          %(logout GET, HEAD  /logout                        #<Proc@#{ @path }:14>)
        ]

        actual = @router.inspector.to_s
        expectations.each do |expectation|
          actual.must_include(expectation)
        end
      end
    end

    describe 'controller action syntax' do
      before do
        @router = Lotus::Router.new do
          get '/controller/action', to: 'welcome#index'
        end
      end

      it 'inspects routes' do
        expectations = [
          %(GET, HEAD  /controller/action             Welcome::Index)
        ]

        actual = @router.inspector.to_s
        expectations.each do |expectation|
          actual.must_include(expectation)
        end
      end
    end

    describe 'lazy controller and action' do
      before do
        @router = Lotus::Router.new do
          get '/lazy', to: 'sleepy#index'
        end

        module Sleepy
          class Index
          end
        end
      end

      after do
        Object.__send__(:remove_const, :Sleepy)
      end

      it 'inspects routes' do
        expectations = [
          %(GET, HEAD  /lazy                          Sleepy::Index)
        ]

        actual = @router.inspector.to_s
        expectations.each do |expectation|
          actual.must_include(expectation)
        end
      end
    end

    describe 'missing controller and action' do
      before do
        @router = Lotus::Router.new do
          get '/missing', to: 'missing#index'
        end
      end

      it 'inspects routes' do
        expectations = [
          %(GET, HEAD  /missing                       Missing::Index)
        ]

        actual = @router.inspector.to_s
        expectations.each do |expectation|
          actual.must_include(expectation)
        end
      end
    end

    describe 'class' do
      before do
        @router = Lotus::Router.new do
          get '/class', to: RackMiddleware
        end
      end

      it 'inspects routes' do
        expectations = [
          %(GET, HEAD  /class                         RackMiddleware)
        ]

        actual = @router.inspector.to_s
        expectations.each do |expectation|
          actual.must_include(expectation)
        end
      end
    end

    describe 'object' do
      before do
        @router = Lotus::Router.new do
          get '/class',  to: RackMiddlewareInstanceMethod
          get '/object', to: RackMiddlewareInstanceMethod.new
        end
      end

      it 'inspects routes' do
        expectations = [
          %(GET, HEAD  /class                         #<RackMiddlewareInstanceMethod>),
          %(GET, HEAD  /object                        #<RackMiddlewareInstanceMethod>)
        ]

        actual = @router.inspector.to_s
        expectations.each do |expectation|
          actual.must_include(expectation)
        end
      end
    end

    describe 'resource' do
      before do
        @router = Lotus::Router.new do
          resource 'identity'
        end
      end

      it 'inspects routes' do
        expectations = [
          %( new_identity GET, HEAD  /identity/new                  Identity::New),
          %(     identity POST       /identity                      Identity::Create),
          %(     identity GET, HEAD  /identity                      Identity::Show),
          %(edit_identity GET, HEAD  /identity/edit                 Identity::Edit),
          %(     identity PATCH      /identity                      Identity::Update),
          %(     identity DELETE     /identity                      Identity::Destroy)
        ]

        actual = @router.inspector.to_s
        expectations.each do |expectation|
          actual.must_include(expectation)
        end
      end
    end

    describe 'resources' do
      before do
        @router = Lotus::Router.new do
          resources 'books'
        end
      end

      it 'inspects routes' do
        expectations = [
         %(     books GET, HEAD  /books                         Books::Index),
          %( new_book GET, HEAD  /books/new                     Books::New),
         %(     books POST       /books                         Books::Create),
          %(     book GET, HEAD  /books/:id                     Books::Show),
          %(edit_book GET, HEAD  /books/:id/edit                Books::Edit),
          %(     book PATCH      /books/:id                     Books::Update),
          %(     book DELETE     /books/:id                     Books::Destroy)
        ]

        actual = @router.inspector.to_s
        expectations.each do |expectation|
          actual.must_include(expectation)
        end
      end
    end

    describe 'with custom formatter' do
      before do
        @router = Lotus::Router.new do
          get '/login', to: ->(env) { }, as: :login
        end
      end

      it 'inspects routes' do
        formatter     = "| %{methods} | %{name} | %{path} | %{endpoint} |\n"
        expectations  = [
          %(| GET, HEAD | login | /login | #<Proc@#{ @path }:189 (lambda)> |)
        ]

        actual = @router.inspector.to_s(formatter)
        expectations.each do |expectation|
          actual.must_include(expectation)
        end
      end
    end

    describe 'nested routes' do
      before do
        class AdminLotusApp
          def call(env)
          end

          def routes
            Lotus::Router.new do
              get '/home', to: 'home#index'
            end
          end
        end

        inner_router = Lotus::Router.new {
          get '/comments', to: 'comments#index'
        }
        nested_router = Lotus::Router.new {
          get '/posts', to: 'posts#index'
          mount inner_router, at: '/second_mount'
        }

        @router = Lotus::Router.new do
          get '/fakeroute', to: 'fake#index'
          mount AdminLotusApp,  at: '/admin'
          mount nested_router,  at: '/api'
          mount RackMiddleware, at: '/class'
          mount RackMiddlewareInstanceMethod,     at: '/instance_from_class'
          mount RackMiddlewareInstanceMethod.new, at: '/instance'
        end
      end

      it 'inspect routes' do
        formatter     = "| %{methods} | %{name} | %{path} | %{endpoint} |\n"
        expectations  = [
          %(| GET, HEAD |  | /fakeroute | Fake::Index |),
          %(| GET, HEAD |  | /admin/home | Home::Index |),
          %(| GET, HEAD |  | /api/posts | Posts::Index |),
          %(| GET, HEAD |  | /api/second_mount/comments | Comments::Index |),
          %(|  |  | /class | RackMiddleware |),
          %(|  |  | /instance_from_class | #<RackMiddlewareInstanceMethod> |),
          %(|  |  | /instance | #<RackMiddlewareInstanceMethod> |)
        ]

        actual = @router.inspector.to_s(formatter)
        expectations.each do |expectation|
          actual.must_include(expectation)
        end
      end
    end

    describe 'with header option' do
      before do
        @router = Lotus::Router.new do
          get '/controller/action', to: 'welcome#index'
        end
      end

      it 'returns header text' do
        expectation = %(Name Method     Path                           Action)

        actual = @router.inspector.to_s
        actual.must_include(expectation)
      end
    end
  end
end
