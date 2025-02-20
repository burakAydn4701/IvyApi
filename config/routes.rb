Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  namespace :api do
    resources :communities do
      resources :posts, only: [:index]
    end
    resources :posts, only: [:create]
    resources :users
    resources :posts do
      resources :comments, shallow: true
      resource :upvote, only: [:create, :destroy]
      member do
        post 'upvote'
      end
    end
    resources :comments, only: [:index, :show, :create] do
      resource :upvote, only: [:create, :destroy]
      member do
        post 'upvote'
      end
    end
    resources :upvotes, only: [:create, :destroy]
  end
end
