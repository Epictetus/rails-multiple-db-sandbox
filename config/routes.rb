Rails.application.routes.draw do
  resources :schools, only: [:index, :show, :create, :update, :destroy]
  get '/demo', to: 'demo#index'
end
