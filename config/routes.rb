Rails.application.routes.draw do
  namespace :admin do
    resources :users, only: [:index, :destroy]
  end
  
  devise_for :users, controllers: {
    sessions: 'sessions'
  }

  devise_scope :user do
    post 'guest_login', to: 'sessions#new_guest'
  end

  resources :contacts, only: [:new, :create]

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'home#index'
  get 'policy', to: "home#policy"
  resources :users,  only: [:show, :edit, :update] do
    delete :destroy_guest, on: :collection
    resources :items do
      collection do
        post :create_bulk
      end
    end
  end
  resources :analysis_sessions, only: [:show, :destroy] do
    member do
      get :show_item
    end
  end
  get '/users', to: redirect('/users/sign_up')
  get '/contacts', to: redirect('/')
  get '/admin', to: redirect('/')
end
