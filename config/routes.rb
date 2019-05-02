Rails.application.routes.draw do
  # category_pattern = /(?!new$|^\d+$)[-_a-z0-9]+[a-z_]/
  category_slug_pattern = /[a-z]+[-_0-9a-z]*[0-9a-z]/
  post_slug_pattern = /[a-z0-9]+[-_.a-z0-9]*[a-z0-9]+/
  archive_constraints = {
    year: /19\d\d|2[01]\d\d/,
    month: /0[1-9]|1[0-2]/,
    day: /0[1-9]|[12]\d|3[01]/
  }

  concern :check do
    post :check, on: :collection, defaults: { format: :json }
  end

  concern :toggle do
    post :toggle, on: :member, defaults: { format: :json }
  end

  concern :priority do
    post :priority, on: :member, defaults: { format: :json }
  end

  concern :removable_image do
    delete :image, action: :destroy_image, on: :member, defaults: { format: :json }
  end

  concern :lock do
    member do
      put :lock, defaults: { format: :json }
      delete :lock, action: :unlock, defaults: { format: :json }
    end
  end

  resources :post_categories, :posts, :post_tags, :post_images, only: %i[update destroy]
  resources :post_links, :post_attachments, only: :destroy
  resources :editorial_members, only: %i[update destroy]
  resources :featured_posts, only: :destroy

  resources :albums, :photos, only: %i[update destroy]

  resources :events, only: %i[update destroy]
  resources :event_speakers, :event_sponsors, :event_materials, :event_programs, only: %i[update destroy]
  resources :event_participants, only: :destroy

  resources :appeals, only: %i[update destroy]

  resources :themes, only: %i[update destroy]
  resources :user_messages, only: :destroy

  resources :groups, :teams, only: %i[update destroy]

  resources :promo_blocks, :promo_items, only: %i[update destroy]

  resources :regions, only: %i[update destroy]

  scope '(:locale)', constraints: { locale: /ru|en/ } do
    root 'index#index'

    scope 'r/:region_slug' do
      get '/' => 'index#regional', as: :regional_index
      get 'news' => 'news#regional_index', as: :news_in_region
      get 'news/:category_slug' => 'news#regional_category', as: :regional_news_category
      get 'news/:category_slug/:slug' => 'news#regional_news', as: :regional_news_item
    end

    get 'search' => 'search#index'

    get 'donate' => 'about#donate'
    scope 'about' do
      get '/' => 'about#index', as: :about
    end

    controller :index do
      get 'index/main_news' => :main_news, as: :index_main_news, defaults: { format: :json }
      get 'index/regional_news' => :regional_news, as: :index_regional_news, defaults: { format: :json }
    end

    resources :post_categories, except: %i[index show update destroy]
    resources :posts, except: %i[new update destroy] do
      collection do
        get 'search'
        get 'categories/:category_slug' => :category, as: :posts_category, constraints: { category_slug: category_slug_pattern }
        get 'tagged/(:tag_name)' => :tagged, as: :tagged, constraints: { tag_name: /[^\/]+?/ }
        get 'archive/(:year)(-:month)(-:day)' => :archive, as: :archive, constraints: archive_constraints
        get 'rss/zen.xml' => :zen, defaults: { format: :xml }
        get 'rss.xml' => :rss, as: :rss, defaults: { format: :xml }
      end
    end
    resources :post_tags, only: :edit
    resources :post_images, only: %i[edit create]
    resources :post_links, only: :create
    resources :editorial_members, only: %i[new create edit]
    resources :featured_posts, only: :create
    resources :post_illustrations, only: :create

    scope :articles, controller: :articles do
      get '/' => :index, as: :articles
      get 'archive/(:year)(-:month)(-:day)' => :archive, as: :articles_archive, constraints: archive_constraints
      get 'tagged/(:tag_name)' => :tagged, as: :tagged_articles, constraints: { tag_name: /[^\/]+?/ }
      get '/:category_slug' => :category, as: :articles_category, constraints: { category_slug: category_slug_pattern }
      get '/:post_id-:post_slug' => :show, as: :show_article, constraints: { post_id: /\d+/, post_slug: post_slug_pattern }
    end

    scope :news, controller: :news do
      get '/' => :index, as: :news_index
      get 'archive/(:year)(-:month)(-:day)' => :archive, as: :news_archive, constraints: archive_constraints
      get 'tagged/(:tag_name)' => :tagged, as: :tagged_news, constraints: { tag_name: /[^\/]+?/ }
      get '/:category_slug' => :category, as: :news_category, constraints: { category_slug: category_slug_pattern }
      get '/:post_id-:post_slug' => :show, as: :show_news, constraints: { post_id: /\d+/, post_slug: post_slug_pattern }
    end

    scope :blog_posts, controller: :blog_posts do
      get '/' => :index, as: :blog_posts
      get 'archive/(:year)(-:month)(-:day)' => :archive, as: :blog_posts_archive, constraints: archive_constraints
      get 'tagged/(:tag_name)' => :tagged, as: :tagged_blog_posts, constraints: { tag_name: /[^\/]+?/ }
      get '/:category_slug' => :category, as: :blog_posts_category, constraints: { category_slug: category_slug_pattern }
      get '/:post_id-:post_slug' => :show, as: :show_blog_post, constraints: { post_id: /\d+/, post_slug: post_slug_pattern }
    end

    scope :authors, controller: 'authors' do
      get '/' => :index, as: :authors
      get ':slug' => :show, as: :author
    end

    resources :illustrations, only: :create

    resources :albums, except: %i[update destroy]
    resources :photos, except: %i[index update destroy]

    resources :events, except: %i[update destroy]
    resources :event_speakers, :event_sponsors, :event_materials, :event_programs, except: %i[index new show update destroy]
    resources :event_participants, only: :create

    resources :appeals, except: %i[index new show edit update destroy]
    get 'feedback' => 'appeals#new'
    post 'feedback' => 'appeals#create'

    # resources :news, except: [:update, :destroy] do
    #   collection do
    #     get ':category_slug' => :category, as: :category, constraints: { category_slug: category_pattern }
    #     get ':category_slug/:slug' => :show_in_category, as: :news_in_category, constraints: { category_slug: category_pattern }
    #   end
    # end
    # resources :regional_news, only: [:index] do
    #   collection do
    #     get ':category_slug' => :category, as: :category, constraints: { category_slug: category_pattern }
    #     get ':category_slug/:slug' => :show_in_category, as: :news_in_category, constraints: { category_slug: category_pattern }
    #   end
    # end
    # resources :posts, except: [:update, :destroy] do
    #   collection do
    #     get ':category_slug' => :category, as: :category, constraints: { category_slug: category_pattern }
    #     get ':category_slug/:slug' => :show_in_category, as: :post_in_category, constraints: { category_slug: category_pattern }
    #   end
    # end

    resources :themes, except: %i[index show update destroy]

    # resources :entries, except: [:update, :destroy] do
    #   member do
    #     get 'reposts/new' => :new_repost, as: :new_repost
    #     post 'reposts' => :create_repost, as: :create_repost
    #   end
    # end

    resources :user_messages, only: :create

    resources :groups, except: %i[index show update destroy]
    resources :teams, except: %i[index show update destroy]

    resources :promo_blocks, :promo_items, only: %i[new create edit], concerns: :check

    resources :regions, except: %i[update destroy] do
      member do
        get 'children', defaults: { format: :json }
      end
    end

    namespace :admin do
      resources :post_types, only: %i[index show] do
        member do
          get :post_categories
          get :new_post
          get :post_tags
        end
      end
      resources :post_categories, only: :show, concerns: %i[lock priority toggle]
      resources :posts, only: %i[index show], concerns: %i[lock toggle] do
        collection do
          get 'search'
          get 'regions', defaults: { format: :json }
        end
        member do
          get 'images'
        end
      end
      resources :post_tags, only: %i[index show] do
        member do
          get 'posts'
        end
      end
      resources :post_images, only: %i[index show], concerns: %i[priority toggle]

      resources :editorial_members, only: %i[index show], concerns: %i[priority toggle]

      resources :featured_posts, only: :index, concerns: %i[priority]

      scope 'post_links', controller: :post_links do
        post ':id/priority' => :priority, as: :priority_post_link, defaults: { format: :json }
      end

      resources :themes, only: %i[index show]

      resources :groups, only: %i[index show] do
        member do
          get 'users', defaults: { format: :json }
          put 'users/:user_id' => :add_user, as: :user, defaults: { format: :json }
          delete 'users/:user_id' => :remove_user, defaults: { format: :json }
        end
      end
      resources :teams, only: %i[index show], concerns: %i[toggle priority] do
        member do
          put 'privileges/:privilege_id' => :add_privilege, as: :privilege, defaults: { format: :json }
          delete 'privileges/:privilege_id' => :remove_privilege, defaults: { format: :json }
        end
      end

      resources :albums, only: %i[index show], concerns: :toggle do
        member do
          get 'photos'
        end
      end
      resources :photos, only: %i[index show], concerns: :priority

      resources :appeals, only: %i[index show], concerns: :toggle

      resources :events, only: %i[index show], concerns: %i[lock toggle] do
        member do
          get 'participants'
        end
      end
      resources :event_participants, only: %i[index show], concerns: :toggle
      resources :event_speakers, :event_sponsors, only: [], concerns: %i[toggle priority]
      resources :event_materials, only: [], concerns: :toggle
      resources :event_programs, only: :show

      resources :media_folders, only: %i[index show], concerns: :lock
      resources :media_files, only: %i[index show], concerns: :lock

      resources :promo_blocks, only: %i[index show], concerns: :toggle
      resources :promo_blocks, :promo_items, only: :show, concerns: :toggle

      resources :regions, only: %i[index show], concerns: %i[priority toggle]
    end

    namespace :editorial do
      get '/' => 'index#index'

      resources :users, only: %i[index show], concerns: :toggle
    end

    namespace :api, defaults: { format: :json } do
      resources :users, except: %i[new edit], concerns: :toggle do
        member do
          put 'follow'
          delete 'follow' => :unfollow
          put 'privileges/:privilege_id' => :grant_privilege, as: :privilege
          delete 'privileges/:privilege_id' => :revoke_privilege
        end
      end

      resources :illustrations, only: %i[create destroy]
      resources :themes, except: %i[new edit], concerns: :lock do
        member do
          put 'post_categories/:category_id' => :add_post_category, as: :post_category
          delete 'post_categories/:category_id' => :remove_post_category
          put 'news_categories/:category_id' => :add_news_category, as: :news_category
          delete 'news_categories/:category_id' => :remove_news_category
        end
      end
      resources :user_links, except: %i[new edit], concerns: :toggle do
        member do
          delete 'hide'
        end
      end
    end

    namespace :network, defaults: { format: :json } do
      controller :sites do
        put 'sites/:id' => :synchronize, as: :synchronize_site
      end
      scope 'users', controller: :users do
        put ':id' => :synchronize, as: :synchronize_user
      end
      resources :regions, only: %i[create update]
      resources :posts, only: :create
    end

    namespace :my do
      get 'articles' => 'posts#articles'
      get 'news' => 'posts#news_index'
      get 'blog' => 'posts#blog_posts'
      get 'articles/new' => 'posts#new_article', as: :new_article
      get 'news/new' => 'posts#new_news', as: :new_news
      get 'blog_posts/new' => 'posts#new_blog_post', as: :new_blog_post

      resources :posts, except: :new

      resources :comments, only: :index
      resources :entries, only: :index
      resources :messages, only: :index do
        get '/:user_slug' => :dialog, on: :collection, as: :dialog
      end
      resources :notifications, only: :index
      resources :followers, :followees, only: :index
      resources :appeals, only: :index
    end

    scope 'u/:slug', controller: :profiles do
      get 'entries' => :entries, as: :user_profile_entries
      get 'followees', as: :user_profile_followees
    end
  end
end
