# frozen_string_literal: true

Rails.application.routes.draw do
  # category_pattern = /(?!new$|^\d+$)[-_a-z0-9]+[a-z_]/
  category_slug_pattern = /[a-z]+[-_0-9a-z]*[0-9a-z]/
  post_slug_pattern = /[a-z0-9]+[-_.a-z0-9]*[a-z0-9]+/
  archive_constraints = { year: /19\d\d|2[01]\d\d/, month: /0[1-9]|1[0-2]/, day: /0[1-9]|[12]\d|3[01]/ }

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

  resources :sites, except: %i[index show], concerns: :check
  resources :countries, :regions, except: %i[index show], concerns: :check

  resources :albums, :photos, only: %i[update destroy]

  resources :events, only: %i[update destroy]
  resources :event_speakers, :event_sponsors, :event_materials, :event_programs, only: %i[update destroy]
  resources :event_participants, only: :destroy

  resources :appeals, only: %i[update destroy]

  resources :user_messages, only: :destroy

  resources :groups, :teams, only: %i[update destroy]

  resources :promo_blocks, :promo_items, only: %i[update destroy]

  resources :regions, only: %i[update destroy]

  resources :political_forces, :campaigns, :candidates, only: %i[update destroy]

  resources :deed_categories, :deeds, only: %i[destroy update]

  resources :decisions, only: %i[destroy update]
  resources :decision_users, only: %i[destroy update]

  resources :post_categories, :posts, :post_tags, :post_images, only: %i[update destroy]
  resources :post_links, only: :destroy
  resources :editorial_members, only: %i[update destroy]
  resources :featured_posts, only: :destroy
  resources :post_illustrations, only: :create
  resources :post_groups, only: %i[update destroy]
  resources :post_attachments, only: :destroy

  resources :polls, :poll_questions, :poll_answers, only: %i[update destroy]

  scope '(:locale)', constraints: { locale: /ru|en/ } do
    root 'index#index'

    put 'comunit/:table_name/:uuid' => 'network#pull', as: nil
    put 'comunit/:table_name/:id/amend' => 'network#amend', as: nil

    scope 'r/:region_slug' do
      get '/' => 'index#regional', as: :regional_index
      get 'news' => 'news#regional_index', as: :news_in_region
      get 'news/:category_slug' => 'news#regional_category', as: :regional_news_category
      get 'news/:category_slug/:slug' => 'news#regional_news', as: :regional_news_item
    end

    get 'search' => 'search#index'

    controller :index do
      get 'index/main_news' => :main_news, as: :index_main_news, defaults: { format: :json }
      get 'index/regional_news' => :regional_news, as: :index_regional_news, defaults: { format: :json }
    end

    get 'regional_news/:category_slug' => 'news#category', as: :legacy_news_category, constraints: { category_slug: category_slug_pattern }
    get 'regional_news/:category_slug/:slug' => 'news#show_in_category', as: :legacy_news_in_category, constraints: { category_slug: category_slug_pattern }
    get 'posts/:category_slug/:slug' => 'posts#legacy_show', as: nil, constraints: { category_slug: category_slug_pattern }

    resources :albums, except: %i[update destroy]
    resources :photos, except: %i[index update destroy]

    resources :events, except: %i[update destroy]
    resources :event_speakers, :event_sponsors, :event_materials, :event_programs, except: %i[index new show update destroy]
    resources :event_participants, only: :create

    resources :appeals, except: %i[index new show edit update destroy]
    get 'feedback' => 'appeals#new'
    post 'feedback' => 'appeals#create'

    resources :user_messages, only: :create

    resources :groups, except: %i[index show update destroy]
    resources :teams, except: %i[index show update destroy]

    resources :promo_blocks, :promo_items, only: %i[new create edit], concerns: :check

    resources :regions, except: %i[update destroy] do
      member do
        get 'children', defaults: { format: :json }
      end
    end

    resources :campaigns, only: %i[index show], concerns: :check do
      member do
        get 'event-:event_id' => :event, as: :event, constraints: { event_id: /\d+/ }
        scope 'candidate-:candidate_id', constraints: { candidate_id: /\d+/ } do
          get '/' => :candidate, as: :candidate
          post 'join' => :join_team, as: :team_candidate
          get 'mandates' => :mandates, as: :mandates_candidate
        end
        get 'mandate-:mandate_id' => :mandate, as: :mandate, constraints: { mandate_id: /\d+/ }
      end
    end
    resources :candidates, except: %i[index show update destroy], concerns: :check
    resources :political_forces, only: %i[new create edit], concerns: :check

    resources :deed_categories, except: %i[index show update destroy], concerns: :check
    resources :deeds, except: %i[update destroy], concerns: :check do
      get :regions, on: :collection
    end

    resources :decisions, except: %i[delete update], concerns: :check do
      member do
        post 'vote' => :vote
      end
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
        get ':category_slug' => :category, as: :short_category, constraints: { category_slug: category_slug_pattern }
        get ':id-:slug' => :show, constraints: { id: /\d+/, slug: post_slug_pattern }
      end
    end
    resources :post_tags, only: :edit
    resources :post_images, only: %i[edit create]
    resources :post_links, only: :create
    resources :editorial_members, only: %i[new create edit]
    resources :featured_posts, only: :create
    resources :post_groups, only: %i[show new create edit], concerns: :check

    scope :articles, controller: :articles do
      get '/' => :index, as: :articles
      get 'new' => :new, as: :new_article
      get 'archive/(:year)(-:month)(-:day)' => :archive, as: :articles_archive, constraints: archive_constraints
      get 'tagged/(:tag_name)' => :tagged, as: :tagged_articles, constraints: { tag_name: /[^\/]+?/ }
      get '/:category_slug' => :category, as: :articles_category, constraints: { category_slug: category_slug_pattern }
      get '/:post_id-:post_slug' => :show, as: :show_article, constraints: { post_id: /\d+/, post_slug: post_slug_pattern }
    end

    scope :news, controller: :news do
      get '/' => :index, as: :news_index
      get 'new' => :new, as: :new_news
      get 'archive/(:year)(-:month)(-:day)' => :archive, as: :news_archive, constraints: archive_constraints
      get 'tagged/(:tag_name)' => :tagged, as: :tagged_news, constraints: { tag_name: /[^\/]+?/ }
      get '/:category_slug' => :category, as: :news_category, constraints: { category_slug: category_slug_pattern }
      get '/:post_id-:post_slug' => :show, as: :show_news, constraints: { post_id: /\d+/, post_slug: post_slug_pattern }
    end

    scope :blog_posts, controller: :blog_posts do
      get '/' => :index, as: :blog_posts
      get 'new' => :new, as: :new_blog_post
      get 'archive/(:year)(-:month)(-:day)' => :archive, as: :blog_posts_archive, constraints: archive_constraints
      get 'tagged/(:tag_name)' => :tagged, as: :tagged_blog_posts, constraints: { tag_name: /[^\/]+?/ }
      get '/:category_slug' => :category, as: :blog_posts_category, constraints: { category_slug: category_slug_pattern }
      get '/:post_id-:post_slug' => :show, as: :show_blog_post, constraints: { post_id: /\d+/, post_slug: post_slug_pattern }
    end

    scope :authors, controller: 'authors' do
      get '/' => :index, as: :authors
      get ':slug' => :show, as: :author
    end

    scope 'u/:slug', controller: :profiles, constraints: { slug: %r{[^/]+} } do
      get 'posts' => :posts, as: :user_posts
    end

    resources :polls, except: %i[update destroy], concerns: :check do
      member do
        post 'results' => :answer
        get 'results'
      end
    end
    resources :poll_questions, :poll_answers, only: %i[create edit], concerns: :check

    namespace :admin do
      resources :sites, only: %i[index show], concerns: :toggle do
        member do
          get 'users'
          put 'users/:user_id' => :add_user, as: :user, defaults: { format: :json }
          delete 'users/:user_id' => :remove_user, defaults: { format: :json }
        end
      end

      resources :countries, only: %i[index show], concerns: %i[toggle priority] do
        member do
          get 'regions'
        end
      end
      resources :regions, only: :show, concerns: %i[toggle priority]

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

      resources :decisions, only: %i[index show], concerns: :toggle
      resources :decision_users, only: %i[index show]

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

      resources :countries, only: %i[index show]
      resources :regions, only: %i[index show], concerns: %i[priority toggle] do
        member do
          put 'users/:user_id' => :add_user, as: :user
          delete 'users/:user_id' => :remove_user
        end
      end

      resources :political_forces, only: %i[index show] do
        member do
          get 'candidates'
          put 'candidates/:candidate_id' => :add_candidate, as: :candidate, defaults: { format: :json }
          delete 'candidates/:candidate_id' => :remove_candidate
        end
      end
      resources :campaigns, only: %i[index show], concerns: :toggle do
        member do
          get 'candidates'
          get 'candidates/new' => :new_candidate, as: :new_candidate
        end
      end
      resources :candidates, only: %i[index show], concerns: :toggle

      resources :deeds, only: %i[index show], concerns: :toggle
      resources :deed_categories, only: %i[index show], concerns: %i[toggle priority] do
        member do
          put 'deeds/:deed_id' => :add_deed, as: :deed
          delete 'deeds/:deed_id' => :remove_deed
        end
      end

      resources :post_types, only: %i[index show] do
        member do
          get :post_categories
          get :new_post
          get :post_tags
          get :authors
          put 'users/:user_id' => :add_user, as: :user
          delete 'users/:user_id' => :remove_user
        end
      end

      resources :post_categories, only: :show, concerns: %i[toggle priority] do
        member do
          put 'users/:user_id' => :add_user, as: :user
          delete 'users/:user_id' => :remove_user
        end
      end

      resources :posts, only: %i[index show], concerns: %i[lock toggle] do
        get 'search', on: :collection
        get 'images', on: :member
      end

      resources :post_tags, only: %i[index show] do
        get 'posts', on: :member
      end

      resources :post_illustrations, only: %i[index show]
      resources :post_images, only: %i[index show], concerns: %i[toggle priority]

      resources :post_groups, only: %i[index show], concerns: %i[toggle priority] do
        member do
          put 'categories/:category_id' => :add_category, as: :category
          delete 'categories/:category_id' => :remove_category
          put 'tags/:tag_id' => :add_tag, as: :tag
          delete 'tags/:tag_id' => :remove_tag
          get :tags, defaults: { format: :json }
        end
      end
      scope 'post_group_categories/:id', controller: :post_group_categories do
        post 'priority' => :priority, as: :priority_post_group_category, defaults: { format: :json }
      end
      scope 'post_group_tags/:id', controller: :post_group_tags do
        post 'priority' => :priority, as: :priority_post_group_tag, defaults: { format: :json }
      end

      resources :editorial_members, only: %i[index show], concerns: %i[toggle priority] do
        member do
          put 'post_types/:post_type_id' => :add_post_type, as: :post_type
          delete 'post_types/:post_type_id' => :remove_post_type
        end
      end

      resources :featured_posts, only: :index, concerns: :priority

      scope 'post_links', controller: :post_links do
        post ':id/priority' => :priority, as: :priority_post_link, defaults: { format: :json }
      end

      resources :polls, only: %i[index show], concerns: :toggle do
        member do
          get 'users'
          post 'users' => :add_user, defaults: { format: :json }
          delete 'users/:user_id' => :remove_user, as: :user, defaults: { format: :json }
        end
      end
      resources :poll_questions, only: :show, concerns: %i[priority toggle]
      resources :poll_answers, only: :show, concerns: :priority
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
        end
      end

      resources :user_links, except: %i[new edit], concerns: :toggle do
        member do
          delete 'hide'
        end
      end
    end

    namespace :network, defaults: { format: :json } do
      resources :users, only: %i[create update] do
        put 'uuid' => :update_uuid, on: :member
      end
      resources :political_forces, :campaigns, :candidates, only: %i[create update]
    end

    namespace :my do
      resources :entries, only: :index
      resources :appeals, only: :index

      resources :deeds, only: %i[index show] do
        member do
          put 'categories/:category_id' => :add_category, as: :category
          delete 'categories/:category_id' => :remove_category
        end
      end

      get 'articles' => 'posts#articles'
      get 'news' => 'posts#news_index'
      get 'blog' => 'posts#blog_posts'
      get 'articles/new' => 'posts#new_article', as: :new_article
      get 'news/new' => 'posts#new_news', as: :new_news
      get 'blog_posts/new' => 'posts#new_blog_post', as: :new_blog_post

      resources :posts, except: :new
    end

    get 'impeachment/candidates' => 'impeachment#candidates', as: :impeachment_candidates
    get 'impeachment/candidates/:id' => 'impeachment#candidate', as: :impeachment_candidate

    scope 'u/:slug', controller: :profiles do
      get 'entries' => :entries, as: :user_profile_entries
      get 'followees', as: :user_profile_followees
    end
  end
end
