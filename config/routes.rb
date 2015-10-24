Rails.application.routes.draw do
  
  resources :articles
  # Root is the home path
  root 'sessions#home'

  get 'admin/scrape', to: 'scraper#scrape'
<<<<<<< HEAD
=======
  
  get 'admin/email'
>>>>>>> 376bb4b34d1c67dadf9f4aa80e0c7c16d639dff5

  # Sessions URL
  get 'sessions/home', to: 'sessions#home', as: :login
  post 'sessions/login', as: :signin
  delete 'sessions/logout', as: :logout
  
  resources :users, only: [:create,:new,:update,:destroy,:edit]
  get '/interests', to: 'articles#my_interests', as: 'interests'
  get '/search', to: 'articles#search', as: 'search'
end
