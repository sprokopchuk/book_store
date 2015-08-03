Rails.application.routes.draw do

  root 'books#index'
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users,  path: '', path_names: { sign_in: 'login', sign_out: 'logout', password: 'password', registration: 'settings', sign_up: 'register' }, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  get '/books/:id', to: "books#show", as: 'book'
  resources :orders, except: [:edit, :destroy]
  resources :order_items, only: [:create, :destroy]
  resources :ratings, only: :create

  get '/shopping_cart/:id', to: "orders#edit", as: 'shopping_cart'

  resources :books do
    collection do
      get '/categories/:id', to: "books#by_category", as: 'category'
    end
  end
end
