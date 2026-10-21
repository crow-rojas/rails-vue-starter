# frozen_string_literal: true

Rails.application.routes.draw do
  get  "sign_in", to: "sessions#new", as: :sign_in
  post "sign_in", to: "sessions#create"
  get  "sign_up", to: "users#new", as: :sign_up
  post "sign_up", to: "users#create"

  resources :sessions, only: [ :destroy ]
  resource :users, only: [ :destroy ]

  namespace :identity do
    resource :email_verification, only: [ :show, :create ]
    resource :password_reset,     only: [ :new, :edit, :create, :update ]
  end

  get :dashboard, to: "dashboard#index"

  resources :projects

  namespace :settings do
    resource :profile, only: [ :show, :update ]
    resource :password, only: [ :show, :update ]
    resource :email, only: [ :show, :update ]
    resources :sessions, only: [ :index ]
    inertia :appearance
  end

  root "home#index"

  # Served from the root so the service worker's scope is the whole app (ADR-007).
  scope format: false, controller: :pwa do
    get "manifest.json", action: :manifest, as: :pwa_manifest, defaults: { format: :json }
    get "service-worker.js", action: :service_worker, as: :pwa_service_worker, defaults: { format: :js }
    get "offline", action: :offline, as: :pwa_offline
  end

  # Errors and jobs dashboards, only for a signed-in user listed in ADMIN_EMAILS; a 404 for anyone else.
  constraints ->(request) { Session.find_by(id: request.cookie_jar.signed[:session_token])&.user&.admin? } do
    mount SolidErrors::Engine, at: "/admin/errors"
    mount MissionControl::Jobs::Engine, at: "/admin/jobs"
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check
end
