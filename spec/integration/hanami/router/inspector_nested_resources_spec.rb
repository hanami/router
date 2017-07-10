RSpec.describe 'Inspector nested resources' do
  before do
    @router = Hanami::Router.new(namespace: Nested::Controllers) do
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
        resources 'variants', only: %i[index show]
      end
      resources :admins, only: %i[index show], controller: :agents do
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
        expect(@inspector).to match('new_user_post GET, HEAD  /users/:user_id/posts/new      Nested::Controllers::Users::Posts::New')
        expect(@inspector).to match('user_posts POST       /users/:user_id/posts          Nested::Controllers::Users::Posts::Create')
        expect(@inspector).to match('user_post GET, HEAD  /users/:user_id/posts/:id      Nested::Controllers::Users::Posts::Show')
        expect(@inspector).to match('edit_user_post GET, HEAD  /users/:user_id/posts/:id/edit Nested::Controllers::Users::Posts::Edit')
        expect(@inspector).to match('user_post PATCH      /users/:user_id/posts/:id      Nested::Controllers::Users::Posts::Update')
        expect(@inspector).to match('user_post DELETE     /users/:user_id/posts/:id      Nested::Controllers::Users::Posts::Destroy')
      end

      it 'for resources -> resource' do
        expect(@inspector).to match('new_user_avatar GET, HEAD  /users/:user_id/avatar/new     Nested::Controllers::Users::Avatar::New')
        expect(@inspector).to match('user_avatar POST       /users/:user_id/avatar         Nested::Controllers::Users::Avatar::Create')
        expect(@inspector).to match('user_avatar GET, HEAD  /users/:user_id/avatar         Nested::Controllers::Users::Avatar::Show')
        expect(@inspector).to match('edit_user_avatar GET, HEAD  /users/:user_id/avatar/edit    Nested::Controllers::Users::Avatar::Edit')
        expect(@inspector).to match('user_avatar PATCH      /users/:user_id/avatar         Nested::Controllers::Users::Avatar::Update')
        expect(@inspector).to match('user_avatar DELETE     /users/:user_id/avatar         Nested::Controllers::Users::Avatar::Destroy')
      end

      it 'for resource -> resources' do
        expect(@inspector).to match('user_comments GET, HEAD  /user/comments                 Nested::Controllers::User::Comments::Index')
        expect(@inspector).to match('new_user_comment GET, HEAD  /user/comments/new             Nested::Controllers::User::Comments::New')
        expect(@inspector).to match('user_comments POST       /user/comments                 Nested::Controllers::User::Comments::Create')
        expect(@inspector).to match('user_comment GET, HEAD  /user/comments/:id             Nested::Controllers::User::Comments::Show')
        expect(@inspector).to match('edit_user_comment GET, HEAD  /user/comments/:id/edit        Nested::Controllers::User::Comments::Edit')
        expect(@inspector).to match('user_comment PATCH      /user/comments/:id             Nested::Controllers::User::Comments::Update')
        expect(@inspector).to match('user_comment DELETE     /user/comments/:id             Nested::Controllers::User::Comments::Destroy')
      end

      it 'for resource -> resource' do
        expect(@inspector).to match('new_user_api_key GET, HEAD  /user/api_key/new              Nested::Controllers::User::ApiKey::New')
        expect(@inspector).to match('user_api_key POST       /user/api_key                  Nested::Controllers::User::ApiKey::Create')
        expect(@inspector).to match('user_api_key GET, HEAD  /user/api_key                  Nested::Controllers::User::ApiKey::Show')
        expect(@inspector).to match('edit_user_api_key GET, HEAD  /user/api_key/edit             Nested::Controllers::User::ApiKey::Edit')
        expect(@inspector).to match('user_api_key PATCH      /user/api_key                  Nested::Controllers::User::ApiKey::Update')
        expect(@inspector).to match('user_api_key DELETE     /user/api_key                  Nested::Controllers::User::ApiKey::Destroy')
      end

      it 'for deep nested routes' do
        expect(@inspector).to match('user_post_comments GET, HEAD  /users/:user_id/posts/:post_id/comments Nested::Controllers::Users::Posts::Comments::Index')
        expect(@inspector).to match('new_user_post_comment GET, HEAD  /users/:user_id/posts/:post_id/comments/new Nested::Controllers::Users::Posts::Comments::New')
        expect(@inspector).to match('user_post_comments POST       /users/:user_id/posts/:post_id/comments Nested::Controllers::Users::Posts::Comments::Create')
        expect(@inspector).to match('user_post_comment GET, HEAD  /users/:user_id/posts/:post_id/comments/:id Nested::Controllers::Users::Posts::Comments::Show')
        expect(@inspector).to match('edit_user_post_comment GET, HEAD  /users/:user_id/posts/:post_id/comments/:id/edit Nested::Controllers::Users::Posts::Comments::Edit')
        expect(@inspector).to match('user_post_comment PATCH      /users/:user_id/posts/:post_id/comments/:id Nested::Controllers::Users::Posts::Comments::Update')
        expect(@inspector).to match('user_post_comment DELETE     /users/:user_id/posts/:post_id/comments/:id Nested::Controllers::Users::Posts::Comments::Destroy')
        expect(@inspector).to match('user_posts GET, HEAD  /users/:user_id/posts          Nested::Controllers::Users::Posts::Index')
        expect(@inspector).to match('new_user_post GET, HEAD  /users/:user_id/posts/new      Nested::Controllers::Users::Posts::New')
        expect(@inspector).to match('user_posts POST       /users/:user_id/posts          Nested::Controllers::Users::Posts::Create')
        expect(@inspector).to match('user_post GET, HEAD  /users/:user_id/posts/:id      Nested::Controllers::Users::Posts::Show')
        expect(@inspector).to match('edit_user_post GET, HEAD  /users/:user_id/posts/:id/edit Nested::Controllers::Users::Posts::Edit')
        expect(@inspector).to match('user_post PATCH      /users/:user_id/posts/:id      Nested::Controllers::Users::Posts::Update')
        expect(@inspector).to match('user_post DELETE     /users/:user_id/posts/:id      Nested::Controllers::Users::Posts::Destroy')
        expect(@inspector).to match('users GET, HEAD  /users                         Nested::Controllers::Users::Index')
        expect(@inspector).to match('new_user GET, HEAD  /users/new                     Nested::Controllers::Users::New')
        expect(@inspector).to match('users POST       /users                         Nested::Controllers::Users::Create')
        expect(@inspector).to match('user GET, HEAD  /users/:id                     Nested::Controllers::Users::Show')
        expect(@inspector).to match('edit_user GET, HEAD  /users/:id/edit                Nested::Controllers::Users::Edit')
        expect(@inspector).to match('user PATCH      /users/:id                     Nested::Controllers::Users::Update')
        expect(@inspector).to match('user DELETE     /users/:id                     Nested::Controllers::Users::Destroy')
      end

      it 'for collection inside nested routes' do
        expect(@inspector).to match('search_admin_users GET, HEAD  /admin/:admin_id/users/search  Nested::Controllers::Admin::Users::Search')
        expect(@inspector).to match('admin_users GET, HEAD  /admin/:admin_id/users         Nested::Controllers::Admin::Users::Index')
        expect(@inspector).to match('new_admin_user GET, HEAD  /admin/:admin_id/users/new     Nested::Controllers::Admin::Users::New')
        expect(@inspector).to match('admin_users POST       /admin/:admin_id/users         Nested::Controllers::Admin::Users::Create')
        expect(@inspector).to match('admin_user GET, HEAD  /admin/:admin_id/users/:id     Nested::Controllers::Admin::Users::Show')
        expect(@inspector).to match('edit_admin_user GET, HEAD  /admin/:admin_id/users/:id/edit Nested::Controllers::Admin::Users::Edit')
        expect(@inspector).to match('admin_user PATCH      /admin/:admin_id/users/:id     Nested::Controllers::Admin::Users::Update')
        expect(@inspector).to match('admin_user DELETE     /admin/:admin_id/users/:id     Nested::Controllers::Admin::Users::Destroy')
        expect(@inspector).to match('admins GET, HEAD  /admin                         Nested::Controllers::Admin::Index')
        expect(@inspector).to match('new_admin GET, HEAD  /admin/new                     Nested::Controllers::Admin::New')
        expect(@inspector).to match('admins POST       /admin                         Nested::Controllers::Admin::Create')
        expect(@inspector).to match('admin GET, HEAD  /admin/:id                     Nested::Controllers::Admin::Show')
        expect(@inspector).to match('edit_admin GET, HEAD  /admin/:id/edit                Nested::Controllers::Admin::Edit')
        expect(@inspector).to match('admin PATCH      /admin/:id                     Nested::Controllers::Admin::Update')
        expect(@inspector).to match('admin DELETE     /admin/:id                     Nested::Controllers::Admin::Destroy')
      end

      it 'for member inside nested routes' do
        expect(@inspector).to match('configure_organization_project GET, HEAD  /organizations/:organization_id/projects/:id/configure Nested::Controllers::Organizations::Projects::Configure')
        expect(@inspector).to match('organization_projects GET, HEAD  /organizations/:organization_id/projects Nested::Controllers::Organizations::Projects::Index')
        expect(@inspector).to match('new_organization_project GET, HEAD  /organizations/:organization_id/projects/new Nested::Controllers::Organizations::Projects::New')
        expect(@inspector).to match('organization_projects POST       /organizations/:organization_id/projects Nested::Controllers::Organizations::Projects::Create')
        expect(@inspector).to match('organization_project GET, HEAD  /organizations/:organization_id/projects/:id Nested::Controllers::Organizations::Projects::Show')
        expect(@inspector).to match('edit_organization_project GET, HEAD  /organizations/:organization_id/projects/:id/edit Nested::Controllers::Organizations::Projects::Edit')
        expect(@inspector).to match('organization_project PATCH      /organizations/:organization_id/projects/:id Nested::Controllers::Organizations::Projects::Update')
        expect(@inspector).to match('organization_project DELETE     /organizations/:organization_id/projects/:id Nested::Controllers::Organizations::Projects::Destroy')
        expect(@inspector).to match('organizations GET, HEAD  /organizations                 Nested::Controllers::Organizations::Index')
        expect(@inspector).to match('new_organization GET, HEAD  /organizations/new             Nested::Controllers::Organizations::New')
        expect(@inspector).to match('organizations POST       /organizations                 Nested::Controllers::Organizations::Create')
        expect(@inspector).to match('organization GET, HEAD  /organizations/:id             Nested::Controllers::Organizations::Show')
        expect(@inspector).to match('edit_organization GET, HEAD  /organizations/:id/edit        Nested::Controllers::Organizations::Edit')
        expect(@inspector).to match('organization PATCH      /organizations/:id             Nested::Controllers::Organizations::Update')
        expect(@inspector).to match('organization DELETE     /organizations/:id             Nested::Controllers::Organizations::Destroy')
      end
    end
  end

  describe 'request' do
    describe 'users -> posts' do
      it 'should match body' do
        response = @app.get('/users/1/posts', lint: true)
        expect(response.body).to eq('Hello from Nested::Controllers::Users::Posts::Index')
      end
    end

    describe 'users -> avatar' do
      it 'should match body' do
        response = @app.get('/users/1/avatar', lint: true)
        expect(response.body).to eq('Hello from Nested::Controllers::Users::Avatar::Show')
      end
    end

    describe 'users -> posts -> comments' do
      it 'should match body' do
        response = @app.get('/users/1/posts/1/comments', lint: true)
        expect(response.body).to eq('Hello from Nested::Controllers::Users::Posts::Comments::Index')
      end
    end

    describe 'user -> comments' do
      it 'should match body' do
        response = @app.get('/user/comments', lint: true)
        expect(response.body).to eq('Hello from Nested::Controllers::User::Comments::Index')
      end
    end

    describe 'user -> api_key' do
      it 'should match body' do
        response = @app.get('/user/api_key', lint: true)
        expect(response.body).to eq('Hello from Nested::Controllers::User::ApiKey::Show')
      end
    end

    describe 'products -> variants' do
      it 'should match body' do
        response = @app.get('/products/1/variants', lint: true)
        expect(response.body).to eq('Hello from Nested::Controllers::Products::Variants::Index')
        response = @app.get('/products/1/variants/1', lint: true)
        expect(response.body).to eq('Hello from Nested::Controllers::Products::Variants::Show')
      end
    end
  end

  describe 'accept options' do
    it 'should products create all actions' do
      expect(@inspector).to match('products GET, HEAD  /products                      Nested::Controllers::Products::Index')
      expect(@inspector).to match('new_product GET, HEAD  /products/new                  Nested::Controllers::Products::New')
      expect(@inspector).to match('products POST       /products                      Nested::Controllers::Products::Create')
      expect(@inspector).to match('product GET, HEAD  /products/:id                  Nested::Controllers::Products::Show')
      expect(@inspector).to match('edit_product GET, HEAD  /products/:id/edit             Nested::Controllers::Products::Edit')
      expect(@inspector).to match('product PATCH      /products/:id                  Nested::Controllers::Products::Update')
      expect(@inspector).to match('product DELETE     /products/:id                  Nested::Controllers::Products::Destroy')
    end

    it 'should products -> variants only create index and show' do
      expect(@inspector).to match('product_variants GET, HEAD  /products/:product_id/variants Nested::Controllers::Products::Variants::Index')
      expect(@inspector).not_to match('new_product_variant GET, HEAD  /products/:products_id/variants/new Nested::Controllers::Products::Variants::New')
      expect(@inspector).not_to match('product_variants POST       /products/:products_id/variants Nested::Controllers::Products::Variants::Create')
      expect(@inspector).to match('product_variant GET, HEAD  /products/:product_id/variants/:id Nested::Controllers::Products::Variants::Show')
      expect(@inspector).not_to match('edit_product_variant GET, HEAD  /products/:products_id/variants/:id/edit Nested::Controllers::Products::Variants::Edit')
      expect(@inspector).not_to match('product_variant PATCH      /products/:products_id/variants/:id Nested::Controllers::Products::Variants::Update')
      expect(@inspector).not_to match('product_variant DELETE     /products/:products_id/variants/:id Nested::Controllers::Products::Variants::Destroy')
    end
  end

  describe 'accept options in parent and child' do
    it 'should create correct actions' do
      expect(@inspector).to match('admin_comments GET, HEAD  /admins/:admin_id/comments     Nested::Controllers::Topics::Index')
      expect(@inspector).to match('admins GET, HEAD  /admins                        Nested::Controllers::Agents::Index')
      expect(@inspector).to match('admin GET, HEAD  /admins/:id                    Nested::Controllers::Agents::Show')
    end
  end

  describe 'accept options only in parent' do
    it 'should create correct actions' do
      expect(@inspector).to match('center_ticket_customers GET, HEAD  /center/tickets/:ticket_id/customers Nested::Controllers::Tickets::Customers::Index')
      expect(@inspector).to match('new_center_ticket_customer GET, HEAD  /center/tickets/:ticket_id/customers/new Nested::Controllers::Tickets::Customers::New')
      expect(@inspector).to match('center_ticket_customers POST       /center/tickets/:ticket_id/customers Nested::Controllers::Tickets::Customers::Create')
      expect(@inspector).to match('center_ticket_customer GET, HEAD  /center/tickets/:ticket_id/customers/:id Nested::Controllers::Tickets::Customers::Show')
      expect(@inspector).to match('edit_center_ticket_customer GET, HEAD  /center/tickets/:ticket_id/customers/:id/edit Nested::Controllers::Tickets::Customers::Edit')
      expect(@inspector).to match('center_ticket_customer PATCH      /center/tickets/:ticket_id/customers/:id Nested::Controllers::Tickets::Customers::Update')
      expect(@inspector).to match('center_ticket_customer DELETE     /center/tickets/:ticket_id/customers/:id Nested::Controllers::Tickets::Customers::Destroy')
      expect(@inspector).to match('center_ticket GET, HEAD  /center/tickets/:id            Nested::Controllers::Receipts::Show')
    end
  end

  describe 'with namespace' do
    it 'should create correct actions' do
      expect(@inspector).to match('api_user_comments GET, HEAD  /api/users/:user_id/comments   Nested::Controllers::Users::Comments::Index')
      expect(@inspector).to match('api_users GET, HEAD  /api/users                     Nested::Controllers::Users::Index')
    end
  end

  describe 'overriding controller without namespace' do
    before do
      @router = Hanami::Router.new do
        resources :users do
          resources :posts do
            resources :comments, controller: 'posts'
          end
        end
      end

      @inspector = @router.inspector.to_s
    end

    it 'should print correct routes' do
      expect(@inspector).to match('user_post_comments GET, HEAD  /users/:user_id/posts/:post_id/comments Posts::Index')
      expect(@inspector).to match('new_user_post_comment GET, HEAD  /users/:user_id/posts/:post_id/comments/new Posts::New')
      expect(@inspector).to match('user_post_comments POST       /users/:user_id/posts/:post_id/comments Posts::Create')
      expect(@inspector).to match('user_post_comment GET, HEAD  /users/:user_id/posts/:post_id/comments/:id Posts::Show')
      expect(@inspector).to match('edit_user_post_comment GET, HEAD  /users/:user_id/posts/:post_id/comments/:id/edit Posts::Edit')
      expect(@inspector).to match('user_post_comment PATCH      /users/:user_id/posts/:post_id/comments/:id Posts::Update')
      expect(@inspector).to match('user_post_comment DELETE     /users/:user_id/posts/:post_id/comments/:id Posts::Destroy')
      expect(@inspector).to match('user_posts GET, HEAD  /users/:user_id/posts          Users::Posts::Index')
      expect(@inspector).to match('new_user_post GET, HEAD  /users/:user_id/posts/new      Users::Posts::New')
      expect(@inspector).to match('user_posts POST       /users/:user_id/posts          Users::Posts::Create')
      expect(@inspector).to match('user_post GET, HEAD  /users/:user_id/posts/:id      Users::Posts::Show')
      expect(@inspector).to match('edit_user_post GET, HEAD  /users/:user_id/posts/:id/edit Users::Posts::Edit')
      expect(@inspector).to match('user_post PATCH      /users/:user_id/posts/:id      Users::Posts::Update')
      expect(@inspector).to match('user_post DELETE     /users/:user_id/posts/:id      Users::Posts::Destroy')
      expect(@inspector).to match('users GET, HEAD  /users                         Users::Index')
      expect(@inspector).to match('new_user GET, HEAD  /users/new                     Users::New')
      expect(@inspector).to match('users POST       /users                         Users::Create')
      expect(@inspector).to match('user GET, HEAD  /users/:id                     Users::Show')
      expect(@inspector).to match('edit_user GET, HEAD  /users/:id/edit                Users::Edit')
      expect(@inspector).to match('user PATCH      /users/:id                     Users::Update')
      expect(@inspector).to match('user DELETE     /users/:id                     Users::Destroy')
    end
  end
end
