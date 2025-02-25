Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  namespace :api do
    resources :communities do
      get 'posts', on: :member
      resources :posts, only: [:index]
    end
    resources :posts, only: [:create, :update, :destroy]
    resources :users
    resources :posts do
      resources :comments, shallow: true
      resource :upvotes, only: [:create, :destroy]
      member do
        post 'upvote'
      end
    end
    resources :comments, only: [:index, :show, :create, :destroy] do
      resource :upvotes, only: [:create, :destroy]
      member do
        post 'upvote'
      end
    end
    resources :comments, only: [:show, :destroy] do
      resource :upvotes, only: [:create, :destroy]
      resources :comments, only: [:create]
    end
  end
end
