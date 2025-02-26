Rails.application.routes.draw do
  # Health check route
  get "up" => "rails/health#show", as: :rails_health_check

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
  end
end