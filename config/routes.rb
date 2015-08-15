Rails.application.routes.draw do

  root 'books#index'
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users,  path: '', path_names: { sign_in: 'login', sign_out: 'logout', password: 'password', registration: 'settings', sign_up: 'register' }, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  resources :ratings, only: :create
  resources :books, only: [:index, :show], format: false
  resources :orders, except: :destroy do
    member do
      put 'change_state', to: 'orders#change_state', as: "change_state"
    end
  end
  resource :checkout, controller: "orders/checkout", only: [:update], format: false do
    get 'fill_in_address'
    get 'fill_in_delivery'
    get 'fill_in_payment'
    get 'confirm'
    get 'complete/:order_id', to: 'orders/checkout#complete', as: :complete
  end
  resources :order_items, only: [:create, :destroy] do
    collection do
      post :destroy_all
    end
  end
  get '/shopping_cart/', :format => false, to: "orders#edit", as: 'shopping_cart'
end
