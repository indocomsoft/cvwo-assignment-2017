# frozen_string_literal: true

Rails.application.routes.draw do
  root "tasks#index"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :tasks do
    member do
      # RESTful API

      # For the done checkbox
      post "done"
    end
  end

  resources :categories

  # For user login
  get "/login", to: "sessions#new"
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"
  resources :users
end
