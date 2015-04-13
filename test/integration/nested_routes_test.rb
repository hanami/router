require 'test_helper'

describe 'Nested resources' do
  before do
    @router = Lotus::Router.new(namespace: Nested::Controllers) do
      resources :users do
        resources :posts
        resource :avatar
        resources :posts do
          resources :comments
        end
      end

      resource :user do
        resources :comments
        resource :api_key
      end

      resources 'products' do
        resources 'variants', only: [:index, :show]
      end
      resources :admins, only: [:index, :show], controller: :agents do
        resources :comments, only: [:index], controller: :topics
      end

      namespace 'api' do
        resources 'users', only: [:index] do
          resources 'comments', only: [:index]
        end
      end

      resources :admin do
        resources :users do
          collection do
            get '/search'
          end
        end
      end

      resources :organizations do
        resources :projects do
          member do
            get '/configure'
          end
        end
      end

      namespace :center do
        resources :tickets, only: [:show], controller: :receipts do
          resources :customers
        end
      end
    end

    @inspector = @router.inspector.to_s
    @app = Rack::MockRequest.new(@router)
  end

  describe 'inspector' do
    describe 'should print correct routes' do
      it 'for resources -> resources' do
        @inspector.must_match 'users_posts GET, HEAD  /users/:users_id/posts         Nested::Controllers::Users::Posts::Index'
        @inspector.must_match 'new_users_posts GET, HEAD  /users/:users_id/posts/new     Nested::Controllers::Users::Posts::New'
        @inspector.must_match 'users_posts POST       /users/:users_id/posts         Nested::Controllers::Users::Posts::Create'
        @inspector.must_match 'users_posts GET, HEAD  /users/:users_id/posts/:id     Nested::Controllers::Users::Posts::Show'
        @inspector.must_match 'edit_users_posts GET, HEAD  /users/:users_id/posts/:id/edit Nested::Controllers::Users::Posts::Edit'
        @inspector.must_match 'users_posts PATCH      /users/:users_id/posts/:id     Nested::Controllers::Users::Posts::Update'
        @inspector.must_match 'users_posts DELETE     /users/:users_id/posts/:id     Nested::Controllers::Users::Posts::Destroy'
      end

      it 'for resources -> resource' do
        @inspector.must_match 'new_users_avatar GET, HEAD  /users/:users_id/avatar/new    Nested::Controllers::Users::Avatar::New'
        @inspector.must_match 'users_avatar POST       /users/:users_id/avatar        Nested::Controllers::Users::Avatar::Create'
        @inspector.must_match 'users_avatar GET, HEAD  /users/:users_id/avatar        Nested::Controllers::Users::Avatar::Show'
        @inspector.must_match 'edit_users_avatar GET, HEAD  /users/:users_id/avatar/edit   Nested::Controllers::Users::Avatar::Edit'
        @inspector.must_match 'users_avatar PATCH      /users/:users_id/avatar        Nested::Controllers::Users::Avatar::Update'
        @inspector.must_match 'users_avatar DELETE     /users/:users_id/avatar        Nested::Controllers::Users::Avatar::Destroy'
      end

      it 'for resource -> resources' do
        @inspector.must_match 'user_comments GET, HEAD  /user/:user_id/comments        Nested::Controllers::User::Comments::Index'
        @inspector.must_match 'new_user_comments GET, HEAD  /user/:user_id/comments/new    Nested::Controllers::User::Comments::New'
        @inspector.must_match 'user_comments POST       /user/:user_id/comments        Nested::Controllers::User::Comments::Create'
        @inspector.must_match 'user_comments GET, HEAD  /user/:user_id/comments/:id    Nested::Controllers::User::Comments::Show'
        @inspector.must_match 'edit_user_comments GET, HEAD  /user/:user_id/comments/:id/edit Nested::Controllers::User::Comments::Edit'
        @inspector.must_match 'user_comments PATCH      /user/:user_id/comments/:id    Nested::Controllers::User::Comments::Update'
        @inspector.must_match 'user_comments DELETE     /user/:user_id/comments/:id    Nested::Controllers::User::Comments::Destroy'
      end

      it 'for resource -> resource' do
        @inspector.must_match 'new_user_api_key GET, HEAD  /user/:user_id/api_key/new     Nested::Controllers::User::ApiKey::New'
        @inspector.must_match 'user_api_key POST       /user/:user_id/api_key         Nested::Controllers::User::ApiKey::Create'
        @inspector.must_match 'user_api_key GET, HEAD  /user/:user_id/api_key         Nested::Controllers::User::ApiKey::Show'
        @inspector.must_match 'edit_user_api_key GET, HEAD  /user/:user_id/api_key/edit    Nested::Controllers::User::ApiKey::Edit'
        @inspector.must_match 'user_api_key PATCH      /user/:user_id/api_key         Nested::Controllers::User::ApiKey::Update'
        @inspector.must_match 'user_api_key DELETE     /user/:user_id/api_key         Nested::Controllers::User::ApiKey::Destroy'
      end

      it 'for deep nested routes' do
        @inspector.must_match 'users_posts GET, HEAD  /users/:users_id/posts         Nested::Controllers::Users::Posts::Index'
        @inspector.must_match 'new_users_posts GET, HEAD  /users/:users_id/posts/new     Nested::Controllers::Users::Posts::New'
        @inspector.must_match 'users_posts POST       /users/:users_id/posts         Nested::Controllers::Users::Posts::Create'
        @inspector.must_match 'users_posts GET, HEAD  /users/:users_id/posts/:id     Nested::Controllers::Users::Posts::Show'
        @inspector.must_match 'edit_users_posts GET, HEAD  /users/:users_id/posts/:id/edit Nested::Controllers::Users::Posts::Edit'
        @inspector.must_match 'users_posts PATCH      /users/:users_id/posts/:id     Nested::Controllers::Users::Posts::Update'
        @inspector.must_match 'users_posts DELETE     /users/:users_id/posts/:id     Nested::Controllers::Users::Posts::Destroy'
        @inspector.must_match 'users GET, HEAD  /users                         Nested::Controllers::Users::Index'
        @inspector.must_match 'new_users GET, HEAD  /users/new                     Nested::Controllers::Users::New'
        @inspector.must_match 'users POST       /users                         Nested::Controllers::Users::Create'
        @inspector.must_match 'users GET, HEAD  /users/:id                     Nested::Controllers::Users::Show'
        @inspector.must_match 'edit_users GET, HEAD  /users/:id/edit                Nested::Controllers::Users::Edit'
        @inspector.must_match 'users PATCH      /users/:id                     Nested::Controllers::Users::Update'
        @inspector.must_match 'users DELETE     /users/:id                     Nested::Controllers::Users::Destroy'
        @inspector.must_match 'users_posts_comments GET, HEAD  /users/:users_id/posts/:posts_id/comments Nested::Controllers::Users::Posts::Comments::Index'
        @inspector.must_match 'new_users_posts_comments GET, HEAD  /users/:users_id/posts/:posts_id/comments/new Nested::Controllers::Users::Posts::Comments::New'
        @inspector.must_match 'users_posts_comments POST       /users/:users_id/posts/:posts_id/comments Nested::Controllers::Users::Posts::Comments::Create'
        @inspector.must_match 'users_posts_comments GET, HEAD  /users/:users_id/posts/:posts_id/comments/:id Nested::Controllers::Users::Posts::Comments::Show'
        @inspector.must_match 'edit_users_posts_comments GET, HEAD  /users/:users_id/posts/:posts_id/comments/:id/edit Nested::Controllers::Users::Posts::Comments::Edit'
        @inspector.must_match 'users_posts_comments PATCH      /users/:users_id/posts/:posts_id/comments/:id Nested::Controllers::Users::Posts::Comments::Update'
        @inspector.must_match 'users_posts_comments DELETE     /users/:users_id/posts/:posts_id/comments/:id Nested::Controllers::Users::Posts::Comments::Destroy'
      end

      it 'for collection inside nested routes' do
        @inspector.must_match 'search_admin_users GET, HEAD  /admin/:admin_id/users/search  Nested::Controllers::Admin::Users::Search'
        @inspector.must_match 'admin_users GET, HEAD  /admin/:admin_id/users         Nested::Controllers::Admin::Users::Index'
        @inspector.must_match 'new_admin_users GET, HEAD  /admin/:admin_id/users/new     Nested::Controllers::Admin::Users::New'
        @inspector.must_match 'admin_users POST       /admin/:admin_id/users         Nested::Controllers::Admin::Users::Create'
        @inspector.must_match 'admin_users GET, HEAD  /admin/:admin_id/users/:id     Nested::Controllers::Admin::Users::Show'
        @inspector.must_match 'edit_admin_users GET, HEAD  /admin/:admin_id/users/:id/edit Nested::Controllers::Admin::Users::Edit'
        @inspector.must_match 'admin_users PATCH      /admin/:admin_id/users/:id     Nested::Controllers::Admin::Users::Update'
        @inspector.must_match 'admin_users DELETE     /admin/:admin_id/users/:id     Nested::Controllers::Admin::Users::Destroy'
        @inspector.must_match 'admin GET, HEAD  /admin                         Nested::Controllers::Admin::Index'
        @inspector.must_match 'new_admin GET, HEAD  /admin/new                     Nested::Controllers::Admin::New'
        @inspector.must_match 'admin POST       /admin                         Nested::Controllers::Admin::Create'
        @inspector.must_match 'admin GET, HEAD  /admin/:id                     Nested::Controllers::Admin::Show'
        @inspector.must_match 'edit_admin GET, HEAD  /admin/:id/edit                Nested::Controllers::Admin::Edit'
        @inspector.must_match 'admin PATCH      /admin/:id                     Nested::Controllers::Admin::Update'
        @inspector.must_match 'admin DELETE     /admin/:id                     Nested::Controllers::Admin::Destroy'
      end

      it 'for member inside nested routes' do
        @inspector.must_match 'configure_organizations_projects GET, HEAD  /organizations/:organizations_id/projects/:id/configure Nested::Controllers::Organizations::Projects::Configure'
        @inspector.must_match 'organizations_projects GET, HEAD  /organizations/:organizations_id/projects Nested::Controllers::Organizations::Projects::Index'
        @inspector.must_match 'new_organizations_projects GET, HEAD  /organizations/:organizations_id/projects/new Nested::Controllers::Organizations::Projects::New'
        @inspector.must_match 'organizations_projects POST       /organizations/:organizations_id/projects Nested::Controllers::Organizations::Projects::Create'
        @inspector.must_match 'organizations_projects GET, HEAD  /organizations/:organizations_id/projects/:id Nested::Controllers::Organizations::Projects::Show'
        @inspector.must_match 'edit_organizations_projects GET, HEAD  /organizations/:organizations_id/projects/:id/edit Nested::Controllers::Organizations::Projects::Edit'
        @inspector.must_match 'organizations_projects PATCH      /organizations/:organizations_id/projects/:id Nested::Controllers::Organizations::Projects::Update'
        @inspector.must_match 'organizations_projects DELETE     /organizations/:organizations_id/projects/:id Nested::Controllers::Organizations::Projects::Destroy'
        @inspector.must_match 'organizations GET, HEAD  /organizations                 Nested::Controllers::Organizations::Index'
        @inspector.must_match 'new_organizations GET, HEAD  /organizations/new             Nested::Controllers::Organizations::New'
        @inspector.must_match 'organizations POST       /organizations                 Nested::Controllers::Organizations::Create'
        @inspector.must_match 'organizations GET, HEAD  /organizations/:id             Nested::Controllers::Organizations::Show'
        @inspector.must_match 'edit_organizations GET, HEAD  /organizations/:id/edit        Nested::Controllers::Organizations::Edit'
        @inspector.must_match 'organizations PATCH      /organizations/:id             Nested::Controllers::Organizations::Update'
        @inspector.must_match 'organizations DELETE     /organizations/:id             Nested::Controllers::Organizations::Destroy'
      end
    end
  end

  describe 'request' do
    describe 'users -> posts' do
      it 'should match body' do
        response = @app.get('/users/1/posts')
        response.body.must_equal 'Hello from Nested::Controllers::Users::Posts::Index'
      end
    end

    describe 'users -> avatar' do
      it 'should match body' do
        response = @app.get('/users/1/avatar')
        response.body.must_equal 'Hello from Nested::Controllers::Users::Avatar::Show'
      end
    end

    describe 'users -> posts -> comments' do
      it 'should match body' do
        response = @app.get('/users/1/posts/1/comments')
        response.body.must_equal 'Hello from Nested::Controllers::Users::Posts::Comments::Index'
      end
    end

    describe 'user -> comments' do
      it 'should match body' do
        response = @app.get('/user/1/comments')
        response.body.must_equal 'Hello from Nested::Controllers::User::Comments::Index'
      end
    end

    describe 'user -> api_keys' do
      it 'should match body' do
        response = @app.get('/user/1/api_key')
        response.body.must_equal 'Hello from Nested::Controllers::User::ApiKey::Show'
      end
    end

    describe 'products -> variants' do
      it 'should match body' do
        response = @app.get('/products/1/variants')
        response.body.must_equal 'Hello from Nested::Controllers::Products::Variants::Index'
        response = @app.get('/products/1/variants/1')
        response.body.must_equal 'Hello from Nested::Controllers::Products::Variants::Show'
      end
    end
  end

  describe 'accept options' do
    it 'should products create all actions' do
      @inspector.must_match 'products GET, HEAD  /products                      Nested::Controllers::Products::Index'
      @inspector.must_match 'new_products GET, HEAD  /products/new                  Nested::Controllers::Products::New'
      @inspector.must_match 'products POST       /products                      Nested::Controllers::Products::Create'
      @inspector.must_match 'products GET, HEAD  /products/:id                  Nested::Controllers::Products::Show'
      @inspector.must_match 'edit_products GET, HEAD  /products/:id/edit             Nested::Controllers::Products::Edit'
      @inspector.must_match 'products PATCH      /products/:id                  Nested::Controllers::Products::Update'
      @inspector.must_match 'products DELETE     /products/:id                  Nested::Controllers::Products::Destroy'
    end

    it 'should products -> variants only create index and show' do
      @inspector.must_match 'products_variants GET, HEAD  /products/:products_id/variants Nested::Controllers::Products::Variants::Index'
      @inspector.must_match 'products_variants GET, HEAD  /products/:products_id/variants Nested::Controllers::Products::Variants::Index'
      @inspector.wont_match 'new_products_variants GET, HEAD  /products/:products_id/variants/new Nested::Controllers::Products::Variants::New'
      @inspector.wont_match 'products_variants POST       /products/:products_id/variants Nested::Controllers::Products::Variants::Create'
      @inspector.must_match 'products_variants GET, HEAD  /products/:products_id/variants/:id Nested::Controllers::Products::Variants::Show'
      @inspector.wont_match 'edit_products_variants GET, HEAD  /products/:products_id/variants/:id/edit Nested::Controllers::Products::Variants::Edit'
      @inspector.wont_match 'products_variants PATCH      /products/:products_id/variants/:id Nested::Controllers::Products::Variants::Update'
      @inspector.wont_match 'products_variants DELETE     /products/:products_id/variants/:id Nested::Controllers::Products::Variants::Destroy'
    end
  end

  describe 'accept options in parent and child' do
    it 'should create correct actions' do
      @inspector.must_match 'admins_comments GET, HEAD  /admins/:admins_id/comments    Nested::Controllers::Topics::Index'
      @inspector.must_match 'admins GET, HEAD  /admins                        Nested::Controllers::Agents::Index'
      @inspector.must_match 'admins GET, HEAD  /admins/:id                    Nested::Controllers::Agents::Show'
    end
  end

  describe 'accept options only in parent' do
    it 'should create correct actions' do
      @inspector.must_match 'center_tickets_customers GET, HEAD  /center/tickets/:tickets_id/customers Nested::Controllers::Tickets::Customers::Index'
      @inspector.must_match 'new_center_tickets_customers GET, HEAD  /center/tickets/:tickets_id/customers/new Nested::Controllers::Tickets::Customers::New'
      @inspector.must_match 'center_tickets_customers POST       /center/tickets/:tickets_id/customers Nested::Controllers::Tickets::Customers::Create'
      @inspector.must_match 'center_tickets_customers GET, HEAD  /center/tickets/:tickets_id/customers/:id Nested::Controllers::Tickets::Customers::Show'
      @inspector.must_match 'edit_center_tickets_customers GET, HEAD  /center/tickets/:tickets_id/customers/:id/edit Nested::Controllers::Tickets::Customers::Edit'
      @inspector.must_match 'center_tickets_customers PATCH      /center/tickets/:tickets_id/customers/:id Nested::Controllers::Tickets::Customers::Update'
      @inspector.must_match 'center_tickets_customers DELETE     /center/tickets/:tickets_id/customers/:id Nested::Controllers::Tickets::Customers::Destroy'
      @inspector.must_match 'center_tickets GET, HEAD  /center/tickets/:id            Nested::Controllers::Receipts::Show'
    end
  end

  describe 'with namespace' do
    it 'should create correct actions' do
      @inspector.must_match 'api_users_comments GET, HEAD  /api/users/:users_id/comments  Nested::Controllers::Users::Comments::Index'
      @inspector.must_match 'api_users GET, HEAD  /api/users                     Nested::Controllers::Users::Index'
    end
  end

  describe 'overriding controller without namesapce' do
    before do
      @router = Lotus::Router.new do
        resources :houses do
          resources :rooms do
            resources :chairs, controller: 'chairs'
          end
        end
      end

      @inspector = @router.inspector.to_s
    end

    it 'should print correct routes' do
      @inspector.must_match 'houses_rooms_chairs GET, HEAD  /houses/:houses_id/rooms/:rooms_id/chairs Chairs::Index'
      @inspector.must_match 'new_houses_rooms_chairs GET, HEAD  /houses/:houses_id/rooms/:rooms_id/chairs/new Chairs::New'
      @inspector.must_match 'houses_rooms_chairs POST       /houses/:houses_id/rooms/:rooms_id/chairs Chairs::Create'
      @inspector.must_match 'houses_rooms_chairs GET, HEAD  /houses/:houses_id/rooms/:rooms_id/chairs/:id Chairs::Show'
      @inspector.must_match 'edit_houses_rooms_chairs GET, HEAD  /houses/:houses_id/rooms/:rooms_id/chairs/:id/edit Chairs::Edit'
      @inspector.must_match 'houses_rooms_chairs PATCH      /houses/:houses_id/rooms/:rooms_id/chairs/:id Chairs::Update'
      @inspector.must_match 'houses_rooms_chairs DELETE     /houses/:houses_id/rooms/:rooms_id/chairs/:id Chairs::Destroy'
      @inspector.must_match 'houses_rooms GET, HEAD  /houses/:houses_id/rooms       Houses::Rooms::Index'
      @inspector.must_match 'new_houses_rooms GET, HEAD  /houses/:houses_id/rooms/new   Houses::Rooms::New'
      @inspector.must_match 'houses_rooms POST       /houses/:houses_id/rooms       Houses::Rooms::Create'
      @inspector.must_match 'houses_rooms GET, HEAD  /houses/:houses_id/rooms/:id   Houses::Rooms::Show'
      @inspector.must_match 'edit_houses_rooms GET, HEAD  /houses/:houses_id/rooms/:id/edit Houses::Rooms::Edit'
      @inspector.must_match 'houses_rooms PATCH      /houses/:houses_id/rooms/:id   Houses::Rooms::Update'
      @inspector.must_match 'houses_rooms DELETE     /houses/:houses_id/rooms/:id   Houses::Rooms::Destroy'
      @inspector.must_match 'houses GET, HEAD  /houses                        Houses::Index'
      @inspector.must_match 'new_houses GET, HEAD  /houses/new                    Houses::New'
      @inspector.must_match 'houses POST       /houses                        Houses::Create'
      @inspector.must_match 'houses GET, HEAD  /houses/:id                    Houses::Show'
      @inspector.must_match 'edit_houses GET, HEAD  /houses/:id/edit               Houses::Edit'
      @inspector.must_match 'houses PATCH      /houses/:id                    Houses::Update'
      @inspector.must_match 'houses DELETE     /houses/:id                    Houses::Destroy'
    end
  end
end
