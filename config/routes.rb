Rails.application.routes.draw do
  devise_for :users
  ActiveAdmin.routes(self)

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Root
  root "dashboard#index"

  # Dashboard
  get "dashboard" => "dashboard#index", as: :dashboard

  # HTTP Bins (user-managed request buckets)
  resources :http_bins do
    # Nested: mock rules per bin
    resources :mock_rules, except: %i[index show]
    # Nested: captured requests per bin
    resources :captured_requests, only: %i[show destroy]
  end

  # Ingest endpoint — catches ALL methods on /b/:token/*
  # This MUST be skip_before_action :authenticate_user!
  match "/b/:token", to: "ingest#capture", via: :all, as: :ingest_root
  match "/b/:token/*path", to: "ingest#capture", via: :all, as: :ingest
end
