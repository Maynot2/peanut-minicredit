Rails.application.routes.draw do
  devise_for :users

  root to: 'pages#home'

  resources :users do
    resources :credits, only: [ :index, :show, :new, :create ] do
      resources :payments, only: [ :new, :create ]
    end
  end
  get '/sim' => 'pages#sim'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
