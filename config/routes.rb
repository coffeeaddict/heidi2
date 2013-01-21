Heidi2::Application.routes.draw do
  devise_for :users

  resources :projects do
    resources :repositories do
      member do
        post :hook
      end

      resources :build_instructions

      resources :builds do
        member do
           post 'tail'
        end
      end
    end
  end

  resources :build_events, only: [ :index, :show ]

  root :to => 'home#index'
end
