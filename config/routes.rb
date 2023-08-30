Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'home#index'
  resources :users,  only: [:show, :edit, :update] do
    resources :items do
      collection do
        post :create_bulk
      end
    end
  end
  get '/abc_analysis', to: 'items#abc_analysis'
end
