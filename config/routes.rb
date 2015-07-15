Rails.application.routes.draw do

  devise_for :users
  root 'books#index'
  get '/books/:id', to: "books#show", as: 'book'
end
