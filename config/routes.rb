Rails.application.routes.draw do
  category_pattern = /(?!new$|^\d+$)[-_a-z0-9]+[a-z_]/

  get 'search' => 'search#index'

  get 'donate' => 'about#donate'
  scope 'about' do
    get '/' => 'about#index', as: :about
  end

  controller :index, defaults: { format: :json} do
    get 'index/main_news' => :main_news, as: :index_main_news
    get 'index/regional_news' => :regional_news, as: :index_regional_news
  end

  resources :users, except: [:show]
  resources :tokens, :codes, except: [:index, :show]
  resources :regions, except: [:index, :new, :create, :show, :destroy]

  resources :news_categories, :post_categories, except: [:index, :show]

  resources :illustrations, only: [:create]

  resources :albums
  resources :photos, except: [:index]

  resources :events
  resources :event_speakers, :event_sponsors, :event_materials, :event_programs, except: [:index, :new, :show]

  resources :appeals, except: [:index, :new, :show, :edit, :update]
  get 'feedback' => 'appeals#new'
  post 'feedback' => 'appeals#create'

  resources :news do
    collection do
      get ':category_slug' => :category, as: :category, constraints: { category_slug: category_pattern }
      get ':category_slug/:slug' => :show_in_category, as: :news_in_category, constraints: { category_slug: category_pattern }
    end
  end
  resources :regional_news, only: [:index] do
    collection do
      get ':category_slug' => :category, as: :category, constraints: { category_slug: category_pattern }
      get ':category_slug/:slug' => :show_in_category, as: :news_in_category, constraints: { category_slug: category_pattern }
    end
  end
  resources :posts do
    collection do
      get ':category_slug' => :category, as: :category, constraints: { category_slug: category_pattern }
      get ':category_slug/:slug' => :show_in_category, as: :post_in_category, constraints: { category_slug: category_pattern }
    end
  end

  resources :comments, except: [:index, :new]

  resources :cities, except: [:index, :new, :show]
  resources :themes, except: [:index, :show]

  resources :entries do
    member do
      get 'reposts/new' => :new_repost, as: :new_repost
      post 'reposts' => :create_repost, as: :create_repost
    end
  end

  resources :user_messages, only: [:create, :destroy]

  resources :groups, except: [:index, :show]
  resources :teams, except: [:index, :show]

  namespace :admin do
    resources :regions, only: [:index, :show] do
      get 'cities', on: :member
    end
    resources :news_categories, :post_categories, only: [:index, :show] do
      get 'items', on: :member
    end
    resources :news, only: [:index, :show]
    resources :posts, :tags, only: [:index, :show]
    resources :comments, only: [:index]
    resources :regions, only: [:index, :show] do
      get 'cities', on: :member
    end
    resources :themes, only: [:index, :show]
    resources :entries, only: [:index, :show] do
      get 'comments', on: :member
    end

    resources :groups, only: [:index, :show] do
      member do
        get 'users', defaults: { format: :json }
        put 'users/:user_id' => :add_user, as: :user, defaults: { format: :json }
        delete 'users/:user_id' => :remove_user, defaults: { format: :json }
      end
    end
    resources :teams, only: [:index, :show] do
      member do
        post 'toggle', defaults: { format: :json }
        post 'priority', defaults: { format: :json }
        put 'privileges/:privilege_id' => :add_privilege, as: :privilege, defaults: { format: :json }
        delete 'privileges/:privilege_id' => :remove_privilege, defaults: { format: :json }
      end
    end

    resources :albums, only: [:index, :show] do
      member do
        post 'toggle', defaults: { format: :json }
        get 'photos'
      end
    end
    resources :photos, only: [:index, :show] do
      member do
        post 'priority', defaults: { format: :json }
      end
    end

    resources :appeals, only: [:index, :show] do
      member do
        post 'toggle', defaults: { format: :json }
      end
    end

    resources :events, only: [:index, :show] do
      member do
        post 'toggle', defaults: { format: :json }
        put 'lock', defaults: { format: :json }
        delete 'lock', action: :unlock, defaults: { format: :json }
        get 'participants'
      end
    end
    resources :event_participants, only: [:show] do
      member do
        post 'toggle', defaults: { format: :json }
      end
    end
    resources :event_speakers, :event_sponsors, only: [] do
      member do
        post 'toggle', defaults: { format: :json }
        post 'priority', defaults: { format: :json }
      end
    end
    resources :event_materials, only: [] do
      member do
        post 'toggle', defaults: { format: :json }
      end
    end
    resources :event_programs, only: [:show]
  end

  namespace :api, defaults: { format: :json } do
    resources :users, except: [:new, :edit] do
      member do
        put 'follow'
        delete 'follow' => :unfollow
        put 'privileges/:privilege_id' => :grant_privilege, as: :privilege
        delete 'privileges/:privilege_id' => :revoke_privilege
        post 'toggle'
      end
    end
    resources :regions, except: [:new, :edit] do
      member do
        post 'toggle'
        put 'lock'
        delete 'lock', action: :unlock
      end
    end
    resources :news_categories, :post_categories, except: [:new, :edit] do
      member do
        put 'lock'
        delete 'lock', action: :unlock
        post 'priority'
        post 'toggle'
      end
    end

    resources :news, :posts, except: [:new, :edit] do
      member do
        post 'toggle'
        put 'lock'
        delete 'lock', action: :unlock
        put 'category'
      end
    end

    resources :illustrations, only: [:create, :destroy]
    resources :comments, except: [:new, :edit] do
      member do
        post 'toggle'
        put 'lock'
        delete 'lock', action: :unlock
      end
    end
    resources :cities, except: [:new, :edit] do
      member do
        put 'lock'
        delete 'lock', action: :unlock
      end
    end
    resources :themes, except: [:new, :edit] do
      member do
        put 'lock'
        delete 'lock', action: :unlock
        put 'post_categories/:category_id' => :add_post_category, as: :post_category
        delete 'post_categories/:category_id' => :remove_post_category
        put 'news_categories/:category_id' => :add_news_category, as: :news_category
        delete 'news_categories/:category_id' => :remove_news_category
      end
    end
    resources :user_links, except: [:new, :edit] do
      member do
        post 'toggle'
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
  end

  namespace :my do
    resources :posts, :news, :comments, only: [:index]
    resources :entries, only: [:index]
    resources :comments, only: [:index]
    resources :messages, only: [:index] do
      get '/:user_slug' => :dialog, on: :collection, as: :dialog
    end
    resources :notifications, only: [:index]
    resources :followers, :followees, only: [:index]
    resources :appeals, only: [:index]
  end

  scope 'u/:slug', controller: :profiles do
    get 'entries' => :entries, as: :user_profile_entries
    get 'followees', as: :user_profile_followees
  end
end
