Rails.application.routes.draw do
  devise_for :users, skip: :all
  resources :users, only: [:create]

  resources :tasks, only: [:index, :show, :create, :update, :destroy]

  get '/current_user', to: 'users#current_user'
  post 'login', to: 'users#login'
end