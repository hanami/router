require 'test_helper'

describe Lotus::Router do
  before do
    @router = Lotus::Router.new
    @app    = Rack::MockRequest.new(@router)
  end

  after do
    @router.reset!
  end

  describe 'resource > resource > resource' do
    before do
      @router.resource :user do
        resource :post do
          resource :comment
        end
      end
    end

    describe ':comment' do
      it 'recognizes get new' do
        url = '/user/post/comment/new'
        @router.path(:new_user_post_comment).must_equal url
        @app.request('GET', url, lint: true).body.must_equal 'User::Post::Comment::New'
      end

      it 'recognizes post create' do
        url = '/user/post/comment'
        @router.path(:user_post_comment).must_equal url
        @app.request('POST', url, lint: true).body.must_equal 'User::Post::Comment::Create'
      end

      it 'recognizes get show' do
        url = '/user/post/comment'
        @router.path(:user_post_comment).must_equal url
        @app.request('GET', url, lint: true).body.must_equal 'User::Post::Comment::Show'
      end

      it 'recognizes get edit' do
        url = '/user/post/comment/edit'
        @router.path(:edit_user_post_comment).must_equal url
        @app.request('GET', url, lint: true).body.must_equal 'User::Post::Comment::Edit'
      end

      it 'recognizes patch update' do
        url = '/user/post/comment'
        @router.path(:user_post_comment).must_equal url
        @app.request('PATCH', url, lint: true).body.must_equal 'User::Post::Comment::Update'
      end

      it 'recognizes delete destroy' do
        url = '/user/post/comment'
        @router.path(:user_post_comment).must_equal url
        @app.request('DELETE', url, lint: true).body.must_equal 'User::Post::Comment::Destroy'
      end
    end

    describe ':post' do
      it 'recognizes get new' do
        url = '/user/post/new'
        @router.path(:new_user_post).must_equal url
        @app.request('GET', url, lint: true).body.must_equal 'User::Post::New'
      end

      it 'recognizes post create' do
        url = '/user/post'
        @router.path(:user_post).must_equal url
        @app.request('POST', url, lint: true).body.must_equal 'User::Post::Create'
      end

      it 'recognizes get show' do
        url = '/user/post'
        @router.path(:user_post).must_equal url
        @app.request('GET', url, lint: true).body.must_equal 'User::Post::Show'
      end

      it 'recognizes get edit' do
        url = '/user/post/edit'
        @router.path(:edit_user_post).must_equal url
        @app.request('GET', url, lint: true).body.must_equal 'User::Post::Edit'
      end

      it 'recognizes patch update' do
        url = '/user/post'
        @router.path(:user_post).must_equal url
        @app.request('PATCH', url, lint: true).body.must_equal 'User::Post::Update'
      end

      it 'recognizes delete destroy' do
        url = '/user/post'
        @router.path(:user_post).must_equal url
        @app.request('DELETE', url, lint: true).body.must_equal 'User::Post::Destroy'
      end
    end

    describe ':user' do
      it 'recognizes get new' do
        url = '/user/new'
        @router.path(:new_user).must_equal url
        @app.request('GET', url, lint: true).body.must_equal 'User::New'
      end

      it 'recognizes create' do
        url = '/user'
        @router.path(:user).must_equal url
        @app.request('POST', url, lint: true).body.must_equal 'User::Create'
      end

      it 'recognizes get show' do
        url = '/user'
        @router.path(:user).must_equal url
        @app.request('GET', url, lint: true).body.must_equal 'User::Show'
      end

      it 'recognizes get edit' do
        url = '/user/edit'
        @router.path(:edit_user).must_equal url
        @app.request('GET', url, lint: true).body.must_equal 'User::Edit'
      end

      it 'recognizes patch update' do
        url = '/user'
        @router.path(:user).must_equal url
        @app.request('PATCH', url, lint: true).body.must_equal 'User::Update'
      end

      it 'recognizes delete destroy' do
        url = '/user'
        @router.path(:user).must_equal url
        @app.request('DELETE', url, lint: true).body.must_equal 'User::Destroy'
      end
    end
  end

  describe 'resource > resource > resources' do
    before do
      @router.resource :user do
        resource :post do
          resources :comments
        end
      end
    end

    describe ':comments' do
      it 'recognizes get index' do
        url = '/user/post/comments'
        @router.path(:user_post_comments).must_equal url
        @app.request('GET', url, lint: true).body.must_equal 'User::Post::Comments::Index'
      end

      it 'recognizes get new' do
        url = '/user/post/comments/new'
        @router.path(:new_user_post_comment).must_equal url
        @app.request('GET', url, lint: true).body.must_equal 'User::Post::Comments::New'
      end

      it 'recognizes post create' do
        url = '/user/post/comments'
        @router.path(:user_post_comments).must_equal url
        @app.request('POST', url, lint: true).body.must_equal 'User::Post::Comments::Create'
      end

      it 'recognizes get show' do
        url = '/user/post/comments/1'
        @router.path(:user_post_comment, id: 1).must_equal url
        @app.request('GET', url, lint: true).body.must_equal 'User::Post::Comments::Show'
      end

      it 'recognizes get edit' do
        url = '/user/post/comments/1/edit'
        @router.path(:edit_user_post_comment, id: 1).must_equal url
        @app.request('GET', url, lint: true).body.must_equal 'User::Post::Comments::Edit'
      end

      it 'recognizes patch update' do
        url = '/user/post/comments/1'
        @router.path(:user_post_comment, id: 1).must_equal url
        @app.request('PATCH', url, lint: true).body.must_equal 'User::Post::Comments::Update'
      end

      it 'recognizes delete destroy' do
        url = '/user/post/comments/1'
        @router.path(:user_post_comment, id: 1).must_equal url
        @app.request('DELETE', url, lint: true).body.must_equal 'User::Post::Comments::Destroy'
      end
    end
  end

  describe 'resource > resources > resources' do
    before do
      @router.resource :user do
        resources :posts do
          resources :comments
        end
      end
    end

    describe ':comments' do
      it 'recognizes get index' do
        url = '/user/posts/1/comments'
        @router.path(:user_post_comments, post_id: 1).must_equal url
        @app.request('GET', url, lint: true).body.must_equal 'User::Posts::Comments::Index'
      end

      it 'recognizes get new' do
        url = '/user/posts/1/comments/new'
        @router.path(:new_user_post_comment, post_id: 1).must_equal url
        @app.request('GET', url, lint: true).body.must_equal 'User::Posts::Comments::New'
      end

      it 'recognizes post create' do
        url = '/user/posts/1/comments'
        @router.path(:user_post_comments, post_id: 1).must_equal url
        @app.request('POST', url, lint: true).body.must_equal 'User::Posts::Comments::Create'
      end

      it 'recognizes get show' do
        url = '/user/posts/1/comments/1'
        @router.path(:user_post_comment, post_id: 1, id: 1).must_equal url
        @app.request('GET', url, lint: true).body.must_equal 'User::Posts::Comments::Show'
      end

      it 'recognizes get edit' do
        url = '/user/posts/1/comments/1/edit'
        @router.path(:edit_user_post_comment, post_id: 1, id: 1).must_equal url
        @app.request('GET', url, lint: true).body.must_equal 'User::Posts::Comments::Edit'
      end

      it 'recognizes patch update' do
        url = '/user/posts/1/comments/1'
        @router.path(:user_post_comment, post_id: 1, id: 1).must_equal url
        @app.request('PATCH', url, lint: true).body.must_equal 'User::Posts::Comments::Update'
      end

      it 'recognizes delete destroy' do
        url = '/user/posts/1/comments/1'
        @router.path(:user_post_comment, post_id: 1, id: 1).must_equal url
        @app.request('DELETE', url, lint: true).body.must_equal 'User::Posts::Comments::Destroy'
      end
    end

    describe ':posts' do
      it 'recognizes get index' do
        url = '/user/posts'
        @router.path(:user_posts).must_equal url
        @app.request('GET', url, lint: true).body.must_equal 'User::Posts::Index'
      end

      it 'recognizes get new' do
        url = '/user/posts/new'
        @router.path(:new_user_post).must_equal url
        @app.request('GET', url, lint: true).body.must_equal 'User::Posts::New'
      end

      it 'recognizes post create' do
        url = '/user/posts'
        @router.path(:user_posts).must_equal url
        @app.request('POST', url, lint: true).body.must_equal 'User::Posts::Create'
      end

      it 'recognizes get show' do
        url = '/user/posts/1'
        @router.path(:user_post, 1).must_equal url
        @app.request('GET', url, lint: true).body.must_equal 'User::Posts::Show'
      end

      it 'recognizes get edit' do
        url = '/user/posts/1/edit'
        @router.path(:edit_user_post, id: 1).must_equal url
        @app.request('GET', url, lint: true).body.must_equal 'User::Posts::Edit'
      end

      it 'recognizes patch update' do
        url = '/user/posts/1'
        @router.path(:user_post, id: 1).must_equal url
        @app.request('PATCH', url, lint: true).body.must_equal 'User::Posts::Update'
      end

      it 'recognizes delete destroy' do
        url = '/user/posts/1'
        @router.path(:user_post, id: 1).must_equal url
        @app.request('DELETE', url, lint: true).body.must_equal 'User::Posts::Destroy'
      end
    end
  end

  describe 'resource > resources > resource' do
    before do
      @router.resource :user do
        resources :posts do
          resource :comment
        end
      end
    end

    describe ':comment' do
      it 'recognizes get new' do
        url = '/user/posts/1/comment/new'
        @router.path(:new_user_post_comment, post_id: 1).must_equal url
        @app.request('GET', url, lint: true).body.must_equal 'User::Posts::Comment::New'
      end

      it 'recognizes post create' do
        url = '/user/posts/1/comment'
        @router.path(:user_post_comment, post_id: 1).must_equal url
        @app.request('POST', url, lint: true).body.must_equal 'User::Posts::Comment::Create'
      end

      it 'recognizes get show' do
        url = '/user/posts/1/comment'
        @router.path(:user_post_comment, post_id: 1).must_equal url
        @app.request('GET', url, lint: true).body.must_equal 'User::Posts::Comment::Show'
      end

      it 'recognizes get edit' do
        url = '/user/posts/1/comment/edit'
        @router.path(:edit_user_post_comment, post_id: 1).must_equal url
        @app.request('GET', url, lint: true).body.must_equal 'User::Posts::Comment::Edit'
      end

      it 'recognizes patch update' do
        url = '/user/posts/1/comment'
        @router.path(:user_post_comment, post_id: 1).must_equal url
        @app.request('PATCH', url, lint: true).body.must_equal 'User::Posts::Comment::Update'
      end

      it 'recognizes delete destroy' do
        url = '/user/posts/1/comment'
        @router.path(:user_post_comment, post_id: 1).must_equal url
        @app.request('DELETE', url, lint: true).body.must_equal 'User::Posts::Comment::Destroy'
      end
    end
  end

  describe 'resources > resources > resources' do
    before do
      @router.resources :users do
        resources :posts do
          resources :comments
        end
      end
    end

    describe ':comments' do
      it 'recognizes get index' do
        url = '/users/1/posts/1/comments'
        @router.path(:user_post_comments, user_id: 1, post_id: 1).must_equal url
        @app.request('GET', url, lint: true).body.must_equal 'Users::Posts::Comments::Index'
      end

      it 'recognizes get new' do
        url = '/users/1/posts/1/comments/new'
        @router.path(:new_user_post_comment, user_id: 1, post_id: 1).must_equal url
        @app.request('GET', url, lint: true).body.must_equal 'Users::Posts::Comments::New'
      end

      it 'recognizes post create' do
        url = '/users/1/posts/1/comments'
        @router.path(:user_post_comments, user_id: 1, post_id: 1).must_equal url
        @app.request('POST', url, lint: true).body.must_equal 'Users::Posts::Comments::Create'
      end

      it 'recognizes get show' do
        url = '/users/1/posts/1/comments/1'
        @router.path(:user_post_comment, user_id: 1, post_id: 1, id: 1).must_equal url
        @app.request('GET', url, lint: true).body.must_equal 'Users::Posts::Comments::Show'
      end

      it 'recognizes get edit' do
        url = '/users/1/posts/1/comments/1/edit'
        @router.path(:edit_user_post_comment, user_id: 1, post_id: 1, id: 1).must_equal url
        @app.request('GET', url, lint: true).body.must_equal 'Users::Posts::Comments::Edit'
      end

      it 'recognizes patch update' do
        url = '/users/1/posts/1/comments/1'
        @router.path(:user_post_comment, user_id: 1, post_id: 1, id: 1).must_equal url
        @app.request('PATCH', url, lint: true).body.must_equal 'Users::Posts::Comments::Update'
      end

      it 'recognizes delete destroy' do
        url = '/users/1/posts/1/comments/1'
        @router.path(:user_post_comment, user_id: 1, post_id: 1, id: 1).must_equal url
        @app.request('DELETE', url, lint: true).body.must_equal 'Users::Posts::Comments::Destroy'
      end
    end

    describe ':posts' do
      it 'recognizes get index' do
        url = '/users/1/posts'
        @router.path(:user_posts, user_id: 1).must_equal url
        @app.request('GET', url, lint: true).body.must_equal 'Users::Posts::Index'
      end

      it 'recognizes get new' do
        url = '/users/1/posts/new'
        @router.path(:new_user_post, user_id: 1).must_equal url
        @app.request('GET', url, lint: true).body.must_equal 'Users::Posts::New'
      end

      it 'recognizes post create' do
        url = '/users/1/posts'
        @router.path(:user_posts, user_id: 1).must_equal url
        @app.request('POST', url, lint: true).body.must_equal 'Users::Posts::Create'
      end

      it 'recognizes get show' do
        url = '/users/1/posts/1'
        @router.path(:user_post, user_id: 1, id: 1).must_equal url
        @app.request('GET', url, lint: true).body.must_equal 'Users::Posts::Show'
      end

      it 'recognizes get edit' do
        url = '/users/1/posts/1/edit'
        @router.path(:edit_user_post, user_id: 1, id: 1).must_equal url
        @app.request('GET', url, lint: true).body.must_equal 'Users::Posts::Edit'
      end

      it 'recognizes patch update' do
        url = '/users/1/posts/1'
        @router.path(:user_post, user_id: 1, id: 1).must_equal url
        @app.request('PATCH', url, lint: true).body.must_equal 'Users::Posts::Update'
      end

      it 'recognizes delete destroy' do
        url = '/users/1/posts/1'
        @router.path(:user_post, user_id: 1, id: 1).must_equal url
        @app.request('DELETE', url, lint: true).body.must_equal 'Users::Posts::Destroy'
      end
    end

    describe ':users' do
      it 'recognizes get index' do
        url = '/users'
        @router.path(:users).must_equal url
        @app.request('GET', url, lint: true).body.must_equal 'Users::Index'
      end

      it 'recognizes get new' do
        url = '/users/new'
        @router.path(:new_user).must_equal url
        @app.request('GET', url, lint: true).body.must_equal 'Users::New'
      end

      it 'recognizes create' do
        url = '/users'
        @router.path(:users).must_equal url
        @app.request('POST', url, lint: true).body.must_equal 'Users::Create'
      end

      it 'recognizes get show' do
        url = '/users/1'
        @router.path(:user, id: 1).must_equal url
        @app.request('GET', url, lint: true).body.must_equal 'Users::Show'
      end

      it 'recognizes get edit' do
        url = '/users/1/edit'
        @router.path(:edit_user, id: 1).must_equal url
        @app.request('GET', url, lint: true).body.must_equal 'Users::Edit'
      end

      it 'recognizes patch update' do
        url = '/users/1'
        @router.path(:user, id: 1).must_equal url
        @app.request('PATCH', url, lint: true).body.must_equal 'Users::Update'
      end

      it 'recognizes delete destroy' do
        url = '/users/1'
        @router.path(:user, id: 1).must_equal url
        @app.request('DELETE', url, lint: true).body.must_equal 'Users::Destroy'
      end
    end
  end

  describe 'resources > resources > resource' do
    before do
      @router.resources :users do
        resources :posts do
          resource :comment
        end
      end
    end

    describe ':comment' do
      it 'recognizes get new' do
        url = '/users/1/posts/1/comment/new'
        @router.path(:new_user_post_comment, user_id: 1, post_id: 1).must_equal url
        @app.request('GET', url, lint: true).body.must_equal 'Users::Posts::Comment::New'
      end

      it 'recognizes post create' do
        url = '/users/1/posts/1/comment'
        @router.path(:user_post_comment, user_id: 1, post_id: 1).must_equal url
        @app.request('POST', url, lint: true).body.must_equal 'Users::Posts::Comment::Create'
      end

      it 'recognizes get show' do
        url = '/users/1/posts/1/comment'
        @router.path(:user_post_comment, user_id: 1, post_id: 1).must_equal url
        @app.request('GET', url, lint: true).body.must_equal 'Users::Posts::Comment::Show'
      end

      it 'recognizes get edit' do
        url = '/users/1/posts/1/comment/edit'
        @router.path(:edit_user_post_comment, user_id: 1, post_id: 1).must_equal url
        @app.request('GET', url, lint: true).body.must_equal 'Users::Posts::Comment::Edit'
      end

      it 'recognizes patch update' do
        url = '/users/1/posts/1/comment'
        @router.path(:user_post_comment, user_id: 1, post_id: 1).must_equal url
        @app.request('PATCH', url, lint: true).body.must_equal 'Users::Posts::Comment::Update'
      end

      it 'recognizes delete destroy' do
        url = '/users/1/posts/1/comment'
        @router.path(:user_post_comment, user_id: 1, post_id: 1).must_equal url
        @app.request('DELETE', url, lint: true).body.must_equal 'Users::Posts::Comment::Destroy'
      end
    end
  end

  describe 'resources > resource > resources' do
    before do
      @router.resources :users do
        resource :post do
          resources :comments do
            collection { get 'search' }
            member     { get 'screenshot' }
          end
          collection { get 'search' }
          member     { get 'screenshot' }
        end
        collection { get 'search' }
        member     { get 'screenshot' }
      end
    end

    describe ':comments' do
      it 'recognizes get index' do
        url = '/users/1/post/comments'
        @router.path(:user_post_comments, user_id: 1).must_equal url
        @app.request('GET', url, lint: true).body.must_equal 'Users::Post::Comments::Index'
      end

      it 'recognizes get new' do
        url = '/users/1/post/comments/new'
        @router.path(:new_user_post_comment, user_id: 1).must_equal url
        @app.request('GET', url, lint: true).body.must_equal 'Users::Post::Comments::New'
      end

      it 'recognizes post create' do
        url = '/users/1/post/comments'
        @router.path(:user_post_comments, user_id: 1).must_equal url
        @app.request('POST', url, lint: true).body.must_equal 'Users::Post::Comments::Create'
      end

      it 'recognizes get show' do
        url = '/users/1/post/comments/1'
        @router.path(:user_post_comment, user_id: 1, id: 1).must_equal url
        @app.request('GET', url, lint: true).body.must_equal 'Users::Post::Comments::Show'
      end

      it 'recognizes get edit' do
        url = '/users/1/post/comments/1/edit'
        @router.path(:edit_user_post_comment, user_id: 1, id: 1).must_equal url
        @app.request('GET', url, lint: true).body.must_equal 'Users::Post::Comments::Edit'
      end

      it 'recognizes patch update' do
        url = '/users/1/post/comments/1'
        @router.path(:user_post_comment, user_id: 1, id: 1).must_equal url
        @app.request('PATCH', url, lint: true).body.must_equal 'Users::Post::Comments::Update'
      end

      it 'recognizes delete destroy' do
        url = '/users/1/post/comments/1'
        @router.path(:user_post_comment, user_id: 1, id: 1).must_equal url
        @app.request('DELETE', url, lint: true).body.must_equal 'Users::Post::Comments::Destroy'
      end

      it 'recognizes collection' do
        url = '/users/1/post/comments/search'
        @router.path(:search_user_post_comments, user_id: 1).must_equal url
        @app.request('GET', url, lint: true).body.must_equal 'Users::Post::Comments::Search'
      end

      it 'recognizes member' do
        url = '/users/1/post/comments/1/screenshot'
        @router.path(:screenshot_user_post_comment, 1, 1).must_equal url
        @app.request('GET', url, lint: true).body.must_equal 'Users::Post::Comments::Screenshot'
      end
    end

    describe ':post' do
      it 'recognizes get new' do
        url = '/users/1/post/new'
        @router.path(:new_user_post, user_id: 1).must_equal url
        @app.request('GET', url, lint: true).body.must_equal 'Users::Post::New'
      end

      it 'recognizes post create' do
        url = '/users/1/post'
        @router.path(:user_post, user_id: 1).must_equal url
        @app.request('POST', url, lint: true).body.must_equal 'Users::Post::Create'
      end

      it 'recognizes get show' do
        url = '/users/1/post'
        @router.path(:user_post, user_id: 1).must_equal url
        @app.request('GET', url, lint: true).body.must_equal 'Users::Post::Show'
      end

      it 'recognizes get edit' do
        url = '/users/1/post/edit'
        @router.path(:edit_user_post, user_id: 1).must_equal url
        @app.request('GET', url, lint: true).body.must_equal 'Users::Post::Edit'
      end

      it 'recognizes patch update' do
        url = '/users/1/post'
        @router.path(:user_post, user_id: 1).must_equal url
        @app.request('PATCH', url, lint: true).body.must_equal 'Users::Post::Update'
      end

      it 'recognizes delete destroy' do
        url = '/users/1/post'
        @router.path(:user_post, user_id: 1).must_equal url
        @app.request('DELETE', url, lint: true).body.must_equal 'Users::Post::Destroy'
      end

      it 'recognizes collection' do
        url = '/users/1/post/search'
        @router.path(:search_user_post, user_id: 1).must_equal url
        @app.request('GET', url, lint: true).body.must_equal 'Users::Post::Search'
      end

      it 'recognizes member' do
        url = '/users/1/post/screenshot'
        @router.path(:screenshot_user_post, user_id: 1).must_equal url
        @app.request('GET', url, lint: true).body.must_equal 'Users::Post::Screenshot'
      end
    end
  end

  describe 'resources > resource > resource' do
    before do
      @router.resources :users do
        resource :post do
          resource :comment
        end
      end
    end

    describe ':comment' do
      it 'recognizes get new' do
        url = '/users/1/post/comment/new'
        @router.path(:new_user_post_comment, user_id: 1).must_equal url
        @app.request('GET', url, lint: true).body.must_equal 'Users::Post::Comment::New'
      end

      it 'recognizes post create' do
        url = '/users/1/post/comment'
        @router.path(:user_post_comment, user_id: 1).must_equal url
        @app.request('POST', url, lint: true).body.must_equal 'Users::Post::Comment::Create'
      end

      it 'recognizes get show' do
        url = '/users/1/post/comment'
        @router.path(:user_post_comment, user_id: 1).must_equal url
        @app.request('GET', url, lint: true).body.must_equal 'Users::Post::Comment::Show'
      end

      it 'recognizes get edit' do
        url = '/users/1/post/comment/edit'
        @router.path(:edit_user_post_comment, user_id: 1).must_equal url
        @app.request('GET', url, lint: true).body.must_equal 'Users::Post::Comment::Edit'
      end

      it 'recognizes patch update' do
        url = '/users/1/post/comment'
        @router.path(:user_post_comment, user_id: 1).must_equal url
        @app.request('PATCH', url, lint: true).body.must_equal 'Users::Post::Comment::Update'
      end

      it 'recognizes delete destroy' do
        url = '/users/1/post/comment'
        @router.path(:user_post_comment, user_id: 1).must_equal url
        @app.request('DELETE', url, lint: true).body.must_equal 'Users::Post::Comment::Destroy'
      end
    end
  end
end
