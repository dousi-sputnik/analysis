Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users, controllers: {
    sessions: 'sessions'
  }

  devise_scope :user do
    post 'users/guest_sign_in', to: 'sessions#new_guest'
  end
 
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'home#index'
  resources :users,  only: [:show, :edit, :update] do
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
end
