Rails.application.routes.draw do
  devise_for :users, skip: :all
  resources :users, only: [:show, :create]

  resources :tasks, only: [:index, :show, :create, :update, :destroy] do
    collection do
      get 'uncompleted_tasks'
      get 'completed_tasks'
    end
  end

  post 'login', to: 'users#login'
end