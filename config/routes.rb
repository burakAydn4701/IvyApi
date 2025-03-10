Rails.application.routes.draw do
  # Health check route
  get "up" => "rails/health#show", as: :rails_health_check

  # Mount Action Cable server
  mount ActionCable.server => '/cable'

  namespace :api do
    resources :communities do
      get 'posts', on: :member
      resources :posts, only: [:index]
    end

    resources :posts, only: [:index, :show, :create, :update, :destroy] do
      resources :comments, shallow: true
      resource :upvotes, only: [:create, :destroy]
    end

    resources :users, only: [:create]
    post '/login', to: 'sessions#create'

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
    
    # Chat routes (renamed from conversations)
    resources :chats, only: [:index, :show, :create] do
      resources :messages, only: [:create]
    end
  end
end