Rails.application.routes.draw do
  root to: 'home#index'

  devise_for :authors, path: 'author'
  devise_for :admins, path: 'admin'

  get '/logout', to: 'application#logout', as: :logout
  get '/login', to: 'application#login', as: :login

  namespace :author do
    resources :authors, except: [:index, :show, :destroy]
    resources :submissions, except: [:show] do
    end
    root to: 'submissions#index'
  end

  namespace :admin do
    resources :admins, except: [:index, :show, :destroy]
    resources :degrees, except: [:show, :destroy] do
    end
    root to: 'admin#index'
  end

  match "/404", to: 'errors#render_404', via: :all
  match "/500", to: 'errors#render_500', via: :all
  match "/401", to: 'errors#render_401', via: :all
end
# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
