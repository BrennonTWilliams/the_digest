Rails.application.routes.draw do
  
  resources :articles
  # Root is the home path
  root 'sessions#home'

  get 'admin/scrape', to: 'scraper#scrape'
  
  get 'admin/email'

  # Sessions URL
  get 'sessions/home', to: 'sessions#home', as: :login
  post 'sessions/login', as: :signin
  delete 'sessions/logout', as: :logout
  
  resources :users, only: [:create,:new,:update,:destroy,:edit]
  get '/interests', to: 'articles#my_interests', as: 'interests'
  get '/search', to: 'articles#search', as: 'search'
end
