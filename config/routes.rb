# frozen_string_literal: true

Rails.application.routes.draw do
  # category_pattern = /(?!new$|^\d+$)[-_a-z0-9]+[a-z_]/
  category_slug_pattern = /[a-z]+[-_0-9a-z]*[0-9a-z]/

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

    controller :index do
      get 'index/main_news' => :main_news, as: :index_main_news, defaults: { format: :json }
      get 'index/regional_news' => :regional_news, as: :index_regional_news, defaults: { format: :json }
    end

    get 'regional_news/:category_slug' => 'news#category', as: :legacy_news_category, constraints: { category_slug: category_slug_pattern }
    get 'regional_news/:category_slug/:slug' => 'news#show_in_category', as: :legacy_news_in_category, constraints: { category_slug: category_slug_pattern }

    resources :illustrations, only: :create

    resources :albums, except: %i[update destroy]
    resources :photos, except: %i[index update destroy]

    resources :events, except: %i[update destroy]
    resources :event_speakers, :event_sponsors, :event_materials, :event_programs, except: %i[index new show update destroy]
    resources :event_participants, only: :create

    resources :appeals, except: %i[index new show edit update destroy]
    get 'feedback' => 'appeals#new'
    post 'feedback' => 'appeals#create'

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

    get 'posts/:category_slug/:slug' => 'posts#legacy_show', as: nil, constraints: { category_slug: category_slug_pattern }

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

      resources :countries, only: %i[index show]
      resources :regions, only: %i[index show], concerns: %i[priority toggle] do
        member do
          put 'users/:user_id' => :add_user, as: :user
          delete 'users/:user_id' => :remove_user
        end
      end
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
      resources :users, only: %i[create update] do
        put 'uuid' => :update_uuid, on: :member
      end
      resources :regions, only: %i[create update]
      resources :posts, only: :create
      resources :political_forces, :campaigns, :candidates, only: %i[create update]
    end

    namespace :my do
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
