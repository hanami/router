# frozen_string_literal: true

RSpec.describe Hanami::Router do
  let(:app) { Rack::MockRequest.new(router) }

  context "resource > resource > resource" do
    let(:router) do
      described_class.new do
        resource :user do
          resource :post do
            resource :comment
          end
        end
      end
    end

    context ":comment" do
      it "recognizes get new" do
        url = "/user/post/comment/new"
        expect(router.path(:new_user_post_comment)).to eq(url)
        expect(app.request("GET", url, lint: true).body).to eq("User::Post::Comment::New")
      end

      it "recognizes post create" do
        url = "/user/post/comment"
        expect(router.path(:user_post_comment)).to eq(url)
        expect(app.request("POST", url, lint: true).body).to eq("User::Post::Comment::Create")
      end

      it "recognizes get show" do
        url = "/user/post/comment"
        expect(router.path(:user_post_comment)).to eq(url)
        expect(app.request("GET", url, lint: true).body).to eq("User::Post::Comment::Show")
      end

      it "recognizes get edit" do
        url = "/user/post/comment/edit"
        expect(router.path(:edit_user_post_comment)).to eq(url)
        expect(app.request("GET", url, lint: true).body).to eq("User::Post::Comment::Edit")
      end

      it "recognizes patch update" do
        url = "/user/post/comment"
        expect(router.path(:user_post_comment)).to eq(url)
        expect(app.request("PATCH", url, lint: true).body).to eq("User::Post::Comment::Update")
      end

      it "recognizes delete destroy" do
        url = "/user/post/comment"
        expect(router.path(:user_post_comment)).to eq(url)
        expect(app.request("DELETE", url, lint: true).body).to eq("User::Post::Comment::Destroy")
      end
    end

    context ":post" do
      it "recognizes get new" do
        url = "/user/post/new"
        expect(router.path(:new_user_post)).to eq(url)
        expect(app.request("GET", url, lint: true).body).to eq("User::Post::New")
      end

      it "recognizes post create" do
        url = "/user/post"
        expect(router.path(:user_post)).to eq(url)
        expect(app.request("POST", url, lint: true).body).to eq("User::Post::Create")
      end

      it "recognizes get show" do
        url = "/user/post"
        expect(router.path(:user_post)).to eq(url)
        expect(app.request("GET", url, lint: true).body).to eq("User::Post::Show")
      end

      it "recognizes get edit" do
        url = "/user/post/edit"
        expect(router.path(:edit_user_post)).to eq(url)
        expect(app.request("GET", url, lint: true).body).to eq("User::Post::Edit")
      end

      it "recognizes patch update" do
        url = "/user/post"
        expect(router.path(:user_post)).to eq(url)
        expect(app.request("PATCH", url, lint: true).body).to eq("User::Post::Update")
      end

      it "recognizes delete destroy" do
        url = "/user/post"
        expect(router.path(:user_post)).to eq(url)
        expect(app.request("DELETE", url, lint: true).body).to eq("User::Post::Destroy")
      end
    end

    context ":user" do
      it "recognizes get new" do
        url = "/user/new"
        expect(router.path(:new_user)).to eq(url)
        expect(app.request("GET", url, lint: true).body).to eq("User::New")
      end

      it "recognizes create" do
        url = "/user"
        expect(router.path(:user)).to eq(url)
        expect(app.request("POST", url, lint: true).body).to eq("User::Create")
      end

      it "recognizes get show" do
        url = "/user"
        expect(router.path(:user)).to eq(url)
        expect(app.request("GET", url, lint: true).body).to eq("User::Show")
      end

      it "recognizes get edit" do
        url = "/user/edit"
        expect(router.path(:edit_user)).to eq(url)
        expect(app.request("GET", url, lint: true).body).to eq("User::Edit")
      end

      it "recognizes patch update" do
        url = "/user"
        expect(router.path(:user)).to eq(url)
        expect(app.request("PATCH", url, lint: true).body).to eq("User::Update")
      end

      it "recognizes delete destroy" do
        url = "/user"
        expect(router.path(:user)).to eq(url)
        expect(app.request("DELETE", url, lint: true).body).to eq("User::Destroy")
      end
    end
  end

  context "resource > resource > resources" do
    let(:router) do
      described_class.new do
        resource :user do
          resource :post do
            resources :comments
          end
        end
      end
    end

    context ":comments" do
      it "recognizes get index" do
        url = "/user/post/comments"
        expect(router.path(:user_post_comments)).to eq(url)
        expect(app.request("GET", url, lint: true).body).to eq("User::Post::Comments::Index")
      end

      it "recognizes get new" do
        url = "/user/post/comments/new"
        expect(router.path(:new_user_post_comment)).to eq(url)
        expect(app.request("GET", url, lint: true).body).to eq("User::Post::Comments::New")
      end

      it "recognizes post create" do
        url = "/user/post/comments"
        expect(router.path(:user_post_comments)).to eq(url)
        expect(app.request("POST", url, lint: true).body).to eq("User::Post::Comments::Create")
      end

      it "recognizes get show" do
        url = "/user/post/comments/1"
        expect(router.path(:user_post_comment, id: 1)).to eq(url)
        expect(app.request("GET", url, lint: true).body).to eq("User::Post::Comments::Show")
      end

      it "recognizes get edit" do
        url = "/user/post/comments/1/edit"
        expect(router.path(:edit_user_post_comment, id: 1)).to eq(url)
        expect(app.request("GET", url, lint: true).body).to eq("User::Post::Comments::Edit")
      end

      it "recognizes patch update" do
        url = "/user/post/comments/1"
        expect(router.path(:user_post_comment, id: 1)).to eq(url)
        expect(app.request("PATCH", url, lint: true).body).to eq("User::Post::Comments::Update")
      end

      it "recognizes delete destroy" do
        url = "/user/post/comments/1"
        expect(router.path(:user_post_comment, id: 1)).to eq(url)
        expect(app.request("DELETE", url, lint: true).body).to eq("User::Post::Comments::Destroy")
      end
    end
  end

  context "resource > resources > resources" do
    let(:router) do
      described_class.new do
        resource :user do
          resources :posts do
            resources :comments
          end
        end
      end
    end

    context ":comments" do
      it "recognizes get index" do
        url = "/user/posts/1/comments"
        expect(router.path(:user_post_comments, post_id: 1)).to eq(url)
        expect(app.request("GET", url, lint: true).body).to eq("User::Posts::Comments::Index")
      end

      it "recognizes get new" do
        url = "/user/posts/1/comments/new"
        expect(router.path(:new_user_post_comment, post_id: 1)).to eq(url)
        expect(app.request("GET", url, lint: true).body).to eq("User::Posts::Comments::New")
      end

      it "recognizes post create" do
        url = "/user/posts/1/comments"
        expect(router.path(:user_post_comments, post_id: 1)).to eq(url)
        expect(app.request("POST", url, lint: true).body).to eq("User::Posts::Comments::Create")
      end

      it "recognizes get show" do
        url = "/user/posts/1/comments/1"
        expect(router.path(:user_post_comment, post_id: 1, id: 1)).to eq(url)
        expect(app.request("GET", url, lint: true).body).to eq("User::Posts::Comments::Show")
      end

      it "recognizes get edit" do
        url = "/user/posts/1/comments/1/edit"
        expect(router.path(:edit_user_post_comment, post_id: 1, id: 1)).to eq(url)
        expect(app.request("GET", url, lint: true).body).to eq("User::Posts::Comments::Edit")
      end

      it "recognizes patch update" do
        url = "/user/posts/1/comments/1"
        expect(router.path(:user_post_comment, post_id: 1, id: 1)).to eq(url)
        expect(app.request("PATCH", url, lint: true).body).to eq("User::Posts::Comments::Update")
      end

      it "recognizes delete destroy" do
        url = "/user/posts/1/comments/1"
        expect(router.path(:user_post_comment, post_id: 1, id: 1)).to eq(url)
        expect(app.request("DELETE", url, lint: true).body).to eq("User::Posts::Comments::Destroy")
      end
    end

    context ":posts" do
      it "recognizes get index" do
        url = "/user/posts"
        expect(router.path(:user_posts)).to eq(url)
        expect(app.request("GET", url, lint: true).body).to eq("User::Posts::Index")
      end

      it "recognizes get new" do
        url = "/user/posts/new"
        expect(router.path(:new_user_post)).to eq(url)
        expect(app.request("GET", url, lint: true).body).to eq("User::Posts::New")
      end

      it "recognizes post create" do
        url = "/user/posts"
        expect(router.path(:user_posts)).to eq(url)
        expect(app.request("POST", url, lint: true).body).to eq("User::Posts::Create")
      end

      it "recognizes get show" do
        url = "/user/posts/1"
        expect(router.path(:user_post, id: 1)).to eq(url)
        expect(app.request("GET", url, lint: true).body).to eq("User::Posts::Show")
      end

      it "recognizes get edit" do
        url = "/user/posts/1/edit"
        expect(router.path(:edit_user_post, id: 1)).to eq(url)
        expect(app.request("GET", url, lint: true).body).to eq("User::Posts::Edit")
      end

      it "recognizes patch update" do
        url = "/user/posts/1"
        expect(router.path(:user_post, id: 1)).to eq(url)
        expect(app.request("PATCH", url, lint: true).body).to eq("User::Posts::Update")
      end

      it "recognizes delete destroy" do
        url = "/user/posts/1"
        expect(router.path(:user_post, id: 1)).to eq(url)
        expect(app.request("DELETE", url, lint: true).body).to eq("User::Posts::Destroy")
      end
    end
  end

  context "resource > resources > resource" do
    let(:router) do
      described_class.new do
        resource :user do
          resources :posts do
            resource :comment
          end
        end
      end
    end

    context ":comment" do
      it "recognizes get new" do
        url = "/user/posts/1/comment/new"
        expect(router.path(:new_user_post_comment, post_id: 1)).to eq(url)
        expect(app.request("GET", url, lint: true).body).to eq("User::Posts::Comment::New")
      end

      it "recognizes post create" do
        url = "/user/posts/1/comment"
        expect(router.path(:user_post_comment, post_id: 1)).to eq(url)
        expect(app.request("POST", url, lint: true).body).to eq("User::Posts::Comment::Create")
      end

      it "recognizes get show" do
        url = "/user/posts/1/comment"
        expect(router.path(:user_post_comment, post_id: 1)).to eq(url)
        expect(app.request("GET", url, lint: true).body).to eq("User::Posts::Comment::Show")
      end

      it "recognizes get edit" do
        url = "/user/posts/1/comment/edit"
        expect(router.path(:edit_user_post_comment, post_id: 1)).to eq(url)
        expect(app.request("GET", url, lint: true).body).to eq("User::Posts::Comment::Edit")
      end

      it "recognizes patch update" do
        url = "/user/posts/1/comment"
        expect(router.path(:user_post_comment, post_id: 1)).to eq(url)
        expect(app.request("PATCH", url, lint: true).body).to eq("User::Posts::Comment::Update")
      end

      it "recognizes delete destroy" do
        url = "/user/posts/1/comment"
        expect(router.path(:user_post_comment, post_id: 1)).to eq(url)
        expect(app.request("DELETE", url, lint: true).body).to eq("User::Posts::Comment::Destroy")
      end
    end
  end

  context "resources > resources > resources" do
    let(:router) do
      described_class.new do
        resources :users do
          resources :posts do
            resources :comments
          end
        end
      end
    end

    context ":comments" do
      it "recognizes get index" do
        url = "/users/1/posts/1/comments"
        expect(router.path(:user_post_comments, user_id: 1, post_id: 1)).to eq(url)
        expect(app.request("GET", url, lint: true).body).to eq("Users::Posts::Comments::Index")
      end

      it "recognizes get new" do
        url = "/users/1/posts/1/comments/new"
        expect(router.path(:new_user_post_comment, user_id: 1, post_id: 1)).to eq(url)
        expect(app.request("GET", url, lint: true).body).to eq("Users::Posts::Comments::New")
      end

      it "recognizes post create" do
        url = "/users/1/posts/1/comments"
        expect(router.path(:user_post_comments, user_id: 1, post_id: 1)).to eq(url)
        expect(app.request("POST", url, lint: true).body).to eq("Users::Posts::Comments::Create")
      end

      it "recognizes get show" do
        url = "/users/1/posts/1/comments/1"
        expect(router.path(:user_post_comment, user_id: 1, post_id: 1, id: 1)).to eq(url)
        expect(app.request("GET", url, lint: true).body).to eq("Users::Posts::Comments::Show")
      end

      it "recognizes get edit" do
        url = "/users/1/posts/1/comments/1/edit"
        expect(router.path(:edit_user_post_comment, user_id: 1, post_id: 1, id: 1)).to eq(url)
        expect(app.request("GET", url, lint: true).body).to eq("Users::Posts::Comments::Edit")
      end

      it "recognizes patch update" do
        url = "/users/1/posts/1/comments/1"
        expect(router.path(:user_post_comment, user_id: 1, post_id: 1, id: 1)).to eq(url)
        expect(app.request("PATCH", url, lint: true).body).to eq("Users::Posts::Comments::Update")
      end

      it "recognizes delete destroy" do
        url = "/users/1/posts/1/comments/1"
        expect(router.path(:user_post_comment, user_id: 1, post_id: 1, id: 1)).to eq(url)
        expect(app.request("DELETE", url, lint: true).body).to eq("Users::Posts::Comments::Destroy")
      end
    end

    context ":posts" do
      it "recognizes get index" do
        url = "/users/1/posts"
        expect(router.path(:user_posts, user_id: 1)).to eq(url)
        expect(app.request("GET", url, lint: true).body).to eq("Users::Posts::Index")
      end

      it "recognizes get new" do
        url = "/users/1/posts/new"
        expect(router.path(:new_user_post, user_id: 1)).to eq(url)
        expect(app.request("GET", url, lint: true).body).to eq("Users::Posts::New")
      end

      it "recognizes post create" do
        url = "/users/1/posts"
        expect(router.path(:user_posts, user_id: 1)).to eq(url)
        expect(app.request("POST", url, lint: true).body).to eq("Users::Posts::Create")
      end

      it "recognizes get show" do
        url = "/users/1/posts/1"
        expect(router.path(:user_post, user_id: 1, id: 1)).to eq(url)
        expect(app.request("GET", url, lint: true).body).to eq("Users::Posts::Show")
      end

      it "recognizes get edit" do
        url = "/users/1/posts/1/edit"
        expect(router.path(:edit_user_post, user_id: 1, id: 1)).to eq(url)
        expect(app.request("GET", url, lint: true).body).to eq("Users::Posts::Edit")
      end

      it "recognizes patch update" do
        url = "/users/1/posts/1"
        expect(router.path(:user_post, user_id: 1, id: 1)).to eq(url)
        expect(app.request("PATCH", url, lint: true).body).to eq("Users::Posts::Update")
      end

      it "recognizes delete destroy" do
        url = "/users/1/posts/1"
        expect(router.path(:user_post, user_id: 1, id: 1)).to eq(url)
        expect(app.request("DELETE", url, lint: true).body).to eq("Users::Posts::Destroy")
      end
    end

    context ":users" do
      it "recognizes get index" do
        url = "/users"
        expect(router.path(:users)).to eq(url)
        expect(app.request("GET", url, lint: true).body).to eq("Users::Index")
      end

      it "recognizes get new" do
        url = "/users/new"
        expect(router.path(:new_user)).to eq(url)
        expect(app.request("GET", url, lint: true).body).to eq("Users::New")
      end

      it "recognizes create" do
        url = "/users"
        expect(router.path(:users)).to eq(url)
        expect(app.request("POST", url, lint: true).body).to eq("Users::Create")
      end

      it "recognizes get show" do
        url = "/users/1"
        expect(router.path(:user, id: 1)).to eq(url)
        expect(app.request("GET", url, lint: true).body).to eq("Users::Show")
      end

      it "recognizes get edit" do
        url = "/users/1/edit"
        expect(router.path(:edit_user, id: 1)).to eq(url)
        expect(app.request("GET", url, lint: true).body).to eq("Users::Edit")
      end

      it "recognizes patch update" do
        url = "/users/1"
        expect(router.path(:user, id: 1)).to eq(url)
        expect(app.request("PATCH", url, lint: true).body).to eq("Users::Update")
      end

      it "recognizes delete destroy" do
        url = "/users/1"
        expect(router.path(:user, id: 1)).to eq(url)
        expect(app.request("DELETE", url, lint: true).body).to eq("Users::Destroy")
      end
    end
  end

  context "resources > resources > resource" do
    let(:router) do
      described_class.new do
        resources :users do
          resources :posts do
            resource :comment
          end
        end
      end
    end

    context ":comment" do
      it "recognizes get new" do
        url = "/users/1/posts/1/comment/new"
        expect(router.path(:new_user_post_comment, user_id: 1, post_id: 1)).to eq(url)
        expect(app.request("GET", url, lint: true).body).to eq("Users::Posts::Comment::New")
      end

      it "recognizes post create" do
        url = "/users/1/posts/1/comment"
        expect(router.path(:user_post_comment, user_id: 1, post_id: 1)).to eq(url)
        expect(app.request("POST", url, lint: true).body).to eq("Users::Posts::Comment::Create")
      end

      it "recognizes get show" do
        url = "/users/1/posts/1/comment"
        expect(router.path(:user_post_comment, user_id: 1, post_id: 1)).to eq(url)
        expect(app.request("GET", url, lint: true).body).to eq("Users::Posts::Comment::Show")
      end

      it "recognizes get edit" do
        url = "/users/1/posts/1/comment/edit"
        expect(router.path(:edit_user_post_comment, user_id: 1, post_id: 1)).to eq(url)
        expect(app.request("GET", url, lint: true).body).to eq("Users::Posts::Comment::Edit")
      end

      it "recognizes patch update" do
        url = "/users/1/posts/1/comment"
        expect(router.path(:user_post_comment, user_id: 1, post_id: 1)).to eq(url)
        expect(app.request("PATCH", url, lint: true).body).to eq("Users::Posts::Comment::Update")
      end

      it "recognizes delete destroy" do
        url = "/users/1/posts/1/comment"
        expect(router.path(:user_post_comment, user_id: 1, post_id: 1)).to eq(url)
        expect(app.request("DELETE", url, lint: true).body).to eq("Users::Posts::Comment::Destroy")
      end
    end
  end

  context "resources > resource > resources" do
    let(:router) do
      described_class.new do
        resources :users do
          resource :post do
            resources :comments do
              collection { get "search" }
              member     { get "screenshot" }
            end
            collection { get "search" }
            member     { get "screenshot" }
          end
          collection { get "search" }
          member     { get "screenshot" }
        end
      end
    end

    context ":comments" do
      it "recognizes get index" do
        url = "/users/1/post/comments"
        expect(router.path(:user_post_comments, user_id: 1)).to eq(url)
        expect(app.request("GET", url, lint: true).body).to eq("Users::Post::Comments::Index")
      end

      it "recognizes get new" do
        url = "/users/1/post/comments/new"
        expect(router.path(:new_user_post_comment, user_id: 1)).to eq(url)
        expect(app.request("GET", url, lint: true).body).to eq("Users::Post::Comments::New")
      end

      it "recognizes post create" do
        url = "/users/1/post/comments"
        expect(router.path(:user_post_comments, user_id: 1)).to eq(url)
        expect(app.request("POST", url, lint: true).body).to eq("Users::Post::Comments::Create")
      end

      it "recognizes get show" do
        url = "/users/1/post/comments/1"
        expect(router.path(:user_post_comment, user_id: 1, id: 1)).to eq(url)
        expect(app.request("GET", url, lint: true).body).to eq("Users::Post::Comments::Show")
      end

      it "recognizes get edit" do
        url = "/users/1/post/comments/1/edit"
        expect(router.path(:edit_user_post_comment, user_id: 1, id: 1)).to eq(url)
        expect(app.request("GET", url, lint: true).body).to eq("Users::Post::Comments::Edit")
      end

      it "recognizes patch update" do
        url = "/users/1/post/comments/1"
        expect(router.path(:user_post_comment, user_id: 1, id: 1)).to eq(url)
        expect(app.request("PATCH", url, lint: true).body).to eq("Users::Post::Comments::Update")
      end

      it "recognizes delete destroy" do
        url = "/users/1/post/comments/1"
        expect(router.path(:user_post_comment, user_id: 1, id: 1)).to eq(url)
        expect(app.request("DELETE", url, lint: true).body).to eq("Users::Post::Comments::Destroy")
      end

      it "recognizes collection" do
        url = "/users/1/post/comments/search"
        expect(router.path(:search_user_post_comments, user_id: 1)).to eq(url)
        expect(app.request("GET", url, lint: true).body).to eq("Users::Post::Comments::Search")
      end

      it "recognizes member" do
        url = "/users/1/post/comments/1/screenshot"
        expect(router.path(:screenshot_user_post_comment, user_id: 1, id: 1)).to eq(url)
        expect(app.request("GET", url, lint: true).body).to eq("Users::Post::Comments::Screenshot")
      end
    end

    context ":post" do
      it "recognizes get new" do
        url = "/users/1/post/new"
        expect(router.path(:new_user_post, user_id: 1)).to eq(url)
        expect(app.request("GET", url, lint: true).body).to eq("Users::Post::New")
      end

      it "recognizes post create" do
        url = "/users/1/post"
        expect(router.path(:user_post, user_id: 1)).to eq(url)
        expect(app.request("POST", url, lint: true).body).to eq("Users::Post::Create")
      end

      it "recognizes get show" do
        url = "/users/1/post"
        expect(router.path(:user_post, user_id: 1)).to eq(url)
        expect(app.request("GET", url, lint: true).body).to eq("Users::Post::Show")
      end

      it "recognizes get edit" do
        url = "/users/1/post/edit"
        expect(router.path(:edit_user_post, user_id: 1)).to eq(url)
        expect(app.request("GET", url, lint: true).body).to eq("Users::Post::Edit")
      end

      it "recognizes patch update" do
        url = "/users/1/post"
        expect(router.path(:user_post, user_id: 1)).to eq(url)
        expect(app.request("PATCH", url, lint: true).body).to eq("Users::Post::Update")
      end

      it "recognizes delete destroy" do
        url = "/users/1/post"
        expect(router.path(:user_post, user_id: 1)).to eq(url)
        expect(app.request("DELETE", url, lint: true).body).to eq("Users::Post::Destroy")
      end

      it "recognizes collection" do
        url = "/users/1/post/search"
        expect(router.path(:search_user_post, user_id: 1)).to eq(url)
        expect(app.request("GET", url, lint: true).body).to eq("Users::Post::Search")
      end

      it "recognizes member" do
        url = "/users/1/post/screenshot"
        expect(router.path(:screenshot_user_post, user_id: 1)).to eq(url)
        expect(app.request("GET", url, lint: true).body).to eq("Users::Post::Screenshot")
      end
    end
  end

  context "resources > resource > resource" do
    let(:router) do
      described_class.new do
        resources :users do
          resource :post do
            resource :comment
          end
        end
      end
    end

    context ":comment" do
      it "recognizes get new" do
        url = "/users/1/post/comment/new"
        expect(router.path(:new_user_post_comment, user_id: 1)).to eq(url)
        expect(app.request("GET", url, lint: true).body).to eq("Users::Post::Comment::New")
      end

      it "recognizes post create" do
        url = "/users/1/post/comment"
        expect(router.path(:user_post_comment, user_id: 1)).to eq(url)
        expect(app.request("POST", url, lint: true).body).to eq("Users::Post::Comment::Create")
      end

      it "recognizes get show" do
        url = "/users/1/post/comment"
        expect(router.path(:user_post_comment, user_id: 1)).to eq(url)
        expect(app.request("GET", url, lint: true).body).to eq("Users::Post::Comment::Show")
      end

      it "recognizes get edit" do
        url = "/users/1/post/comment/edit"
        expect(router.path(:edit_user_post_comment, user_id: 1)).to eq(url)
        expect(app.request("GET", url, lint: true).body).to eq("Users::Post::Comment::Edit")
      end

      it "recognizes patch update" do
        url = "/users/1/post/comment"
        expect(router.path(:user_post_comment, user_id: 1)).to eq(url)
        expect(app.request("PATCH", url, lint: true).body).to eq("Users::Post::Comment::Update")
      end

      it "recognizes delete destroy" do
        url = "/users/1/post/comment"
        expect(router.path(:user_post_comment, user_id: 1)).to eq(url)
        expect(app.request("DELETE", url, lint: true).body).to eq("Users::Post::Comment::Destroy")
      end
    end
  end
end
