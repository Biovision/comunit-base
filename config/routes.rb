Rails.application.routes.draw do
  resources :users, except: [:show]
  resources :tokens, :codes, except: [:index, :show]
  resources :privileges, except: [:index, :show]
  resources :regions, except: [:index, :new, :create, :show, :destroy]

  namespace :admin do
    resources :users, only: [:index, :show] do
      member do
        get 'tokens'
        get 'codes'
        get 'privileges'
      end
    end
    resources :tokens, :codes, only: [:index, :show]

    resources :privileges, only: [:index, :show] do
      get 'users', on: :member
    end
    resources :regions, only: [:index, :show] do
      get 'cities', on: :member
    end
  end

  namespace :api, defaults: { format: :json } do
    resources :tokens, except: [:new, :edit] do
      post 'toggle', on: :member
    end
    resources :users, except: [:new, :edit] do
      member do
        put 'follow'
        delete 'follow' => :unfollow
        put 'privileges/:privilege_id' => :grant_privilege, as: :privilege
        delete 'privileges/:privilege_id' => :revoke_privilege
        post 'toggle'
      end
    end
    resources :privileges, except: [:new, :edit] do
      member do
        put 'lock'
        delete 'lock', action: :unlock
        post 'priority'
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
    get '/' => 'index#index'

    resource :profile, except: [:destroy]
    resource :confirmation, :recovery, only: [:show, :create, :update]
  end

  scope 'u/:slug', controller: :profiles do
    get '/' => :show, as: :user_profile
    get 'entries' => :entries, as: :user_profile_entries
    get 'followees', as: :user_profile_followees
  end

  controller :authentication do
    get 'login' => :new
    post 'login' => :create
    delete 'logout' => :destroy
  end
end
