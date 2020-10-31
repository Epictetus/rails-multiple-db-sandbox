Rails.application.routes.draw do
  resources :users, only: [:index, :show, :create, :update, :destroy]
  resources :schools, only: [:index, :show, :create, :update, :destroy]
  get '/demo', to: 'demo#index'
end
