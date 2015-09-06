Rails.application.routes.draw do

  root 'books#home'
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users,  path: '', path_names: { sign_in: 'login', sign_out: 'logout', password: 'password', registration: 'settings', sign_up: 'register' }, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

  resources :users, only: [] do
    resource :wish_list, only: :show do
      post 'add_book/:book_id', to: 'wish_lists#add_book', as: 'add_book_to'
      delete 'remove_book/:book_id', to: 'wish_lists#remove_book', as: 'remove_book_from'
    end
  end
  resources :ratings, only: :create
  resources :books, only: [:index, :show], format: false
  resources :orders, except: [:destroy, :edit, :update]
  resource :checkout, controller: "orders/checkout", only: [:update], format: false do
    get 'address'
    get 'delivery'
    get 'payment'
    get 'confirm'
    get 'complete/:id', to: 'orders/checkout#complete', as: :complete
    post "complete/:id", to: 'orders/checkout#complete'
  end
  resources :order_items, only: [:create, :destroy] do
    collection do
      post :destroy_all
    end
  end
  resource :shopping_cart, controller: "cart", only: [:show, :update], format: false
end
