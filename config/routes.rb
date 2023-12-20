# frozen_string_literal: true
require 'sidekiq/web'

Rails.application.routes.draw do

  devise_for :approvers, path: 'approver'
  devise_for :authors, path: 'author'
  devise_for :admins, path: 'admin'

  get '/logout', to: 'application#logout', as: :logout
  get '/about', to: 'application#about', as: :about_page
  get '/main', to: 'application#main', as: :main_page
  get '/docs', to: 'application#docs', as: :docs_page

  authenticate :author do
    get '/login', to: 'application#login', as: :login
  end

  get '/', to: redirect(path: '/main')

  mount Sidekiq::Web => '/sidekiq'

  mount OkComputer::Engine, at: "/healthcheck"

  ## works: get '/committee_members/autocomplete', to: 'ldap_lookup#autocomplete', as: :committee_members_autocomplete
  get '/committee_members/autocomplete', to: 'application#autocomplete', as: :committee_members_autocomplete

  get '/special_committee/:authentication_token', to: 'special_committee#main', as: :special_committee_main

  post '/special_committee/:authentication_token/advance_to_reviews', to: 'special_committee#advance_to_reviews', as: :advance_to_reviews

  post 'email_contact_form', to: 'email_contact_form#create', as: :email_contact_form_index
  get 'email_contact_form', to: 'email_contact_form#new', as: :email_contact_form_new

  get '/committee_member_dashboard', to: 'committee_member#index', as: :committee_member_dashboard

  namespace :admin do
    resources :admins, except: [:index, :show]
    resources :degrees, except: [:show, :destroy]
    resources :programs, except: [:show, :destroy]
    resources :approval_configurations, except: [:new, :create, :destroy]
    resources :authors,  except: [:new, :create, :show, :destroy]

    get '/custom_report', to: 'reports#custom_report_index', as: :custom_report_index
    patch '/custom_report_export', to: 'reports#custom_report_export', defaults: { format: 'csv' }, as: :custom_report_export
    get '/committee_report', to: 'reports#committee_report_index', as: :committee_report_index
    patch '/committee_report_export', to: 'reports#committee_report_export', defaults: { format: 'csv' }, as: :committee_report_export
    get '/confidential_hold_report', to: 'reports#confidential_hold_report_index', as: :confidential_hold_report_index
    patch '/confidential_hold_report_export', to: 'reports#confidential_hold_report_export', defaults: { format: 'csv' }, as: :confidential_hold_report_export
    get '/committee_member_report', to: 'reports#committee_member_report_index', as: :committee_member_report_index
    patch '/committee_member_report_export', to: 'reports#committee_member_report_export', defaults: { format: 'csv' }, as: :committee_member_report_export


    get '/authors/contact_list', to: 'authors#email_contact_list', as: :email_contact_list

    get '/submissions/:id/edit', to: 'submissions#edit', as: :edit_submission
    delete '/submissions', to: 'submissions#bulk_destroy', as: :delete_submissions

    patch '/submissions/:id/format_review_response', to: 'submissions#record_format_review_response', as: :submissions_format_review_response
    patch '/submissions/:id/final_submission_pending_response', to: 'submissions#record_final_submission_pending_response', as: :submissions_final_submission_pending_response
    patch '/submissions/:id/update_final_submission', to: 'submissions#record_send_back_to_final_submission', as: :submissions_update_final_submission
    patch '/submissions/:id/final_submission_response', to: 'submissions#record_final_submission_response', as: :submissions_final_submission_response
    patch '/submissions/:id/update_released', to: 'submissions#update_released', as: :submissions_update_released
    patch '/submissions/:id/update_waiting_to_be_released', to: 'submissions#update_waiting_to_be_released', as: :submissions_update_waiting_to_be_released
    patch '/submissions/:id', to: 'submissions#update', as: :submission
    get '/submissions/:id/audit', to: 'submissions#audit', as: :submission_audit
    get '/submissions/:id/committee_members_refresh', to: 'submissions#refresh_committee', as: :refresh_committee

    get '/:degree_type', to: 'submissions#dashboard', as: :submissions_dashboard
    get '/:degree_type/:scope', to: 'submissions#index', as: :submissions_index

    get '/submissions/:id/print_signatory_page', to: 'submissions#print_signatory_page', as: :submission_print_signatory_page
    patch '/submissions/:id/print_signatory_page_update', to: 'submissions#print_signatory_page_update', as: :submissions_print_signatory_page_update

    patch '/:degree_type/final_submission_approved', to: 'submissions#release_for_publication', as: :submissions_release_final_submission_approved
    patch '/:degree_type/extend_publication_date', to: 'submissions#extend_publication_date', as: :submissions_extend_publication_date

    patch '/:degree_type/export_final_submission_approved', to: 'reports#final_submission_approved', as: :export_final_submission_approved

    get 'submissions/:id/academic_plan_refresh', to: 'submissions#refresh_academic_plan', as: 'submissions_refresh_academic_plan'

    post 'submissions/:id/send_email_reminder', to: 'submissions#send_email_reminder', as: 'submissions_send_email_reminder'

    get '/files/format_reviews/:id',    to: 'files#download_format_review',    as: :format_review_file
    get '/files/final_submissions/:id', to: 'files#download_final_submission', as: :final_submission_file

    root to: 'submissions#redirect_to_default_dashboard'
  end

  namespace :author do
    resources :authors, except: [:index, :show, :destroy]
    resources :submissions, except: [:show] do
      get '/program_information', to: 'submissions#program_information', as: :program_information
      get '/academic_plan_refresh', to: 'submissions#refresh', as: :refresh

      get '/format_review', to: 'submission_format_review#show', as: :format_review
      get '/format_review/edit', to: 'submission_format_review#edit', as: :edit_format_review
      patch '/format_review', to: 'submission_format_review#update', as: :update_format_review

      get '/final_submission', to: 'submissions#final_submission', as: :final_submission
      get '/final_submission/edit', to: 'submissions#edit_final_submission', as: :edit_final_submission
      patch '/final_submission', to: 'submissions#update_final_submission', as: :update_final_submission
      get '/date_defended_refresh', to: 'submissions#refresh_date_defended', as: :refresh_date_defended

      resource :committee_members, shallow: true # We only modify the set of committee members en masse
      get '/committee_members_refresh', to: 'committee_members#refresh', as: :refresh_committee

      post '/send_email_reminder', to: 'submissions#send_email_reminder'

      get '/committee_review', to: 'submissions#committee_review', as: :committee_review
    end
    get '/published_submissions', to: 'submissions#published_submissions_index', as: :published_submissions_index

    get '/files/format_reviews/:id',    to: 'files#download_format_review',    as: :format_review_file
    get '/files/final_submissions/:id', to: 'files#download_final_submission', as: :final_submission_file

    root to: 'submissions#index'
    get '/tips', to: 'authors#technical_tips', as: :technical_tips
  end

  namespace :approver do
    get '/reviews', to: 'approvers#index', as: :approver_reviews
    get '/committee_member/:id', to: 'approvers#edit'
    patch '/committee_member/:id', to: 'approvers#update', as: :update_committee_member
    get '/special_committee_link/:authentication_token', to: 'approvers#special_committee_link', as: :special_committee_link
    get '/committee_member/:id/committee_reviews', to: 'approvers#committee_reviews', as: :committee_reviews
    get '/files/final_submissions/:id', to: 'approvers#download_final_submission', as: :approver_file
    root to: 'approvers#index'
  end

  root to: 'application#main'
  match "/404", to: 'errors#render_404', via: :all
  match "/500", to: 'errors#render_500', via: :all
  match "/401", to: 'errors#render_401', via: :all
end
# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
