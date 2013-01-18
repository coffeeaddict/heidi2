Heidi2::Application.routes.draw do
  devise_for :users

  resources :projects do
    resources :repositories do
      resources :builds do
        member do
           post 'tail'
        end
      end
    end
  end

  root :to => 'home#index'
end
