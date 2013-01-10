Heidi2::Application.routes.draw do
  devise_for :users

  resources :projects do
    resources :repositories
  end

  root :to => 'projects#index'
end
