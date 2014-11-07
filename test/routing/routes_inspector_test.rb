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
        expected = <<-ROUTES
               login GET, HEAD  /login                         #<Proc@#{ @path }:13 (lambda)>
              logout GET, HEAD  /logout                        #<Proc@#{ @path }:14>
ROUTES

        @router.inspector.to_s.must_equal(expected)
      end
    end

    describe 'controller action syntax' do
      before do
        @router = Lotus::Router.new do
          get '/controller/action', to: 'welcome#index'
        end
      end

      it 'inspects routes'
      # it 'inspects routes' do
      #   expected = <<-ROUTES
      #                GET, HEAD  /controller/action             WelcomeController::Index
# ROUTES

      #   @router.inspector.to_s.must_equal(expected)
      # end
    end

    describe 'lazy controller and action' do
      before do
        @router = Lotus::Router.new do
          get '/lazy', to: 'sleepy#index'
        end

        module SleepyController
          class Index
          end
        end
      end

      after do
        Object.__send__(:remove_const, :SleepyController)
      end

      it 'inspects routes'
      # it 'inspects routes' do
      #   expected = <<-ROUTES
      #                GET, HEAD  /lazy                          LazyController::Index
# ROUTES

      #   @router.inspector.to_s.must_equal(expected)
      # end
    end

    describe 'missing controller and action' do
      before do
        @router = Lotus::Router.new do
          get '/missing', to: 'missing#index'
        end
      end

      it 'inspects routes' do
        expected = <<-ROUTES
                     GET, HEAD  /missing                       Missing(::Controller::|Controller::)Index
ROUTES

        @router.inspector.to_s.must_equal(expected)
      end
    end

    describe 'class' do
      before do
        @router = Lotus::Router.new do
          get '/class', to: RackMiddleware
        end
      end

      it 'inspects routes'
      # it 'inspects routes' do
      #   expected = <<-ROUTES
      #                GET, HEAD  /class                         RackMiddleware
# ROUTES

      #   @router.inspector.to_s.must_equal(expected)
      # end
    end

    describe 'object' do
      before do
        @router = Lotus::Router.new do
          get '/class',  to: RackMiddlewareInstanceMethod
          get '/object', to: RackMiddlewareInstanceMethod.new
        end
      end

      it 'inspects routes' do
        expected = <<-ROUTES
                     GET, HEAD  /class                         #<RackMiddlewareInstanceMethod>
                     GET, HEAD  /object                        #<RackMiddlewareInstanceMethod>
ROUTES

        @router.inspector.to_s.must_equal(expected)
      end
    end

    describe 'resource' do
      before do
        @router = Lotus::Router.new do
          resource 'identity'
        end
      end

      it 'inspects routes' do
        expected = <<-ROUTES
        new_identity GET, HEAD  /identity/new                  Identity(::Controller::|Controller::)New
            identity POST       /identity                      Identity(::Controller::|Controller::)Create
            identity GET, HEAD  /identity                      Identity(::Controller::|Controller::)Show
       edit_identity GET, HEAD  /identity/edit                 Identity(::Controller::|Controller::)Edit
            identity PATCH      /identity                      Identity(::Controller::|Controller::)Update
            identity DELETE     /identity                      Identity(::Controller::|Controller::)Destroy
ROUTES

        @router.inspector.to_s.must_equal(expected)
      end
    end

    describe 'resources' do
      before do
        @router = Lotus::Router.new do
          resources 'books'
        end
      end

      it 'inspects routes' do
        expected = <<-ROUTES
               books GET, HEAD  /books                         Books(::Controller::|Controller::)Index
           new_books GET, HEAD  /books/new                     Books(::Controller::|Controller::)New
               books POST       /books                         Books(::Controller::|Controller::)Create
               books GET, HEAD  /books/:id                     Books(::Controller::|Controller::)Show
          edit_books GET, HEAD  /books/:id/edit                Books(::Controller::|Controller::)Edit
               books PATCH      /books/:id                     Books(::Controller::|Controller::)Update
               books DELETE     /books/:id                     Books(::Controller::|Controller::)Destroy
ROUTES

        @router.inspector.to_s.must_equal(expected)
      end
    end

    describe 'with custom formatter' do
      before do
        @router = Lotus::Router.new do
          get '/login', to: ->(env) { }, as: :login
        end
      end

      it 'inspects routes' do
        formatter = "| %{methods} | %{name} | %{path} | %{endpoint} |\n"
        expected  = <<-ROUTES
| GET, HEAD | login | /login | #<Proc@#{ @path }:168 (lambda)> |
ROUTES

        @router.inspector.to_s(formatter).must_equal(expected)
      end
    end
  end
end
