Rails.application.routes.draw do
  devise_for :users, skip: :all
  resources :users, only: [:create]

  resources :tasks, only: [:index, :show, :create, :update, :destroy] do
    collection do
      get 'uncompleted_tasks'
      get 'completed_tasks'
    end
  end

  get '/current_user', to: 'users#current_user'
  post 'login', to: 'users#login'
end