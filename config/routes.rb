# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'application#index'

  devise_for :authors, path: 'author'
  devise_for :admins, path: 'admin'

  get '/logout', to: 'application#logout', as: :logout
  get '/login', to: 'application#login', as: :login

  namespace :author do
    resources :authors, except: [:index, :show]
    resources :submissions, except: [:show] do
    end
    get '/tips', to: 'authors#technical_tips', as: :technical_tips

    root to: 'submissions#index'
  end

  namespace :admin do
    resources :admins, except: [:index, :show]
    resources :degrees, except: [:show, :destroy]
    resources :programs, except: [:show, :destroy]
    resources :authors,  except: [:new, :create, :show, :destroy]

    get '/:degree_type', to: 'submissions#dashboard', as: :submissions_dashboard
    get '/:degree_type/:scope', to: 'submissions#index', as: :submissions_index

    root to: 'admin#index'
  end

  get '/committee_members/autocomplete', to: 'ldap_lookup#autocomplete', as: :committee_members_autocomplete

  post 'contact_form', to: 'contact_form#create', as: :contact_form_index
  get 'contact_form', to: 'contact_form#new', as: :contact_form_new

  match "/404", to: 'errors#render_404', via: :all
  match "/500", to: 'errors#render_500', via: :all
  match "/401", to: 'errors#render_401', via: :all
end
# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
