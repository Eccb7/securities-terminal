Rails.application.routes.draw do
  # Devise authentication
  devise_for :users

  # API routes for React frontend
  namespace :api do
    namespace :v1 do
      # Dashboard
      get "dashboard", to: "dashboard#index"

      # Current user
      get "current_user", to: "users#current"

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
          delete "remove_security/:item_id", to: "watchlists#remove_security", as: :remove_security
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
    end
  end

  # Root path - Serve React app
  root "react#index"

  # Catch-all route for React Router (must be last)
  # This allows client-side routing to work properly
  get "*path", to: "react#index", constraints: lambda { |req|
    # Don't catch API routes, Rails health check, or asset requests
    !req.path.start_with?("/api", "/rails", "/assets", "/cable") &&
    !req.path.match(/\.(json|xml|csv|pdf|zip)$/)
  }

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
