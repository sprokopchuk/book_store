Rails.application.routes.draw do

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users,  path: '', path_names: { sign_in: 'login', sign_out: 'logout', password: 'password', registration: 'settings', sign_up: 'register' }, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  root 'books#index'
  get '/books/:id', to: "books#show", as: 'book'
end
