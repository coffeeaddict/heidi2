Heidi2::Application.routes.draw do
  devise_for :users

  resources :projects do
    resources :repositories do
      resources :builds do
        member do
          get 'tail'
        end
      end
    end
  end

  root :to => 'projects#index'
end
