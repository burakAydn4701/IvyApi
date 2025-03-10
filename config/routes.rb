Rails.application.routes.draw do
  # Health check route
  get "up" => "rails/health#show", as: :rails_health_check

  # Mount Action Cable server
  mount ActionCable.server => '/cable'

  namespace :api do
    # Public routes
    get 'health', to: 'public#health'
    get 'app_info', to: 'public#app_info'

    # Authentication
    post 'login', to: 'sessions#create'
    delete 'logout', to: 'sessions#destroy'
    resources :sessions, only: [:create, :destroy]
    resources :users, only: [:create]

    # Resources that may have public and private endpoints
    resources :communities do
      get 'posts', on: :member
      resources :posts, only: [:index]
    end

    # User posts route
    get 'users/:user_id/posts', to: 'posts#user_posts', as: 'user_posts'

    # Posts and related resources
    resources :posts, only: [:index, :show, :create, :update, :destroy] do
      resources :comments, shallow: true
      resource :upvotes, only: [:create, :destroy]
    end

    # Chat functionality
    resources :chats, only: [:index, :show, :create] do
      resources :messages, only: [:create]
    end

    # User profiles
    get 'profile', to: 'users#profile'
    patch 'profile', to: 'users#update_profile'

    resources :comments, only: [:index, :show, :create, :destroy] do
      resource :upvotes, only: [:create, :destroy]
      resources :comments, only: [:create], shallow: true
    end

    # Add this line to allow direct upvote creation/deletion
    resources :upvotes, only: [:create, :destroy]

    resources :users do
      member do
        post :update_profile_photo
      end
    end
  end
end