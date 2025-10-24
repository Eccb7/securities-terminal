Rails.application.routes.draw do
  # Devise authentication
  devise_for :users

  # Root path
  root "dashboard#index"

  # Dashboard
  get "dashboard", to: "dashboard#index"
  get "dashboard/market_data", to: "dashboard#market_data"

  # Securities
  resources :securities, only: [ :index, :show ] do
    member do
      get :quote
      get :chart_data
    end

    collection do
      get :search
    end
  end

  # Orders
  resources :orders do
    member do
      post :cancel
      patch :modify
    end

    collection do
      get :active
    end
  end

  # Portfolios
  resources :portfolios do
    resources :positions, only: [ :index, :show ]
  end

  # Watchlists
  resources :watchlists do
    member do
      post :add_security
      delete :remove_security
    end
  end

  # News
  resources :news_items, only: [ :index, :show ]

  # Alerts
  resources :alert_rules
  resources :alert_events, only: [ :index, :show ] do
    member do
      post :resolve
    end
  end

  # Audit logs
  resources :audit_logs, only: [ :index, :show ]

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
