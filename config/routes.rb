Rails.application.routes.draw do
  devise_for :users

  root "dashboard#index"

  resources :threats do
    resources :indicators, only: [:new, :create]
    resources :mitre_attacks, only: [:new, :create, :destroy]
    resources :vulnerabilities, only: [:new, :create]
  end

  resources :indicators, only: [:index, :show, :edit, :update, :destroy] do
    collection do
      get :search
    end
  end

  resources :vulnerabilities, only: [:index, :show, :edit, :update, :destroy]
  resources :threat_feeds

  get "dashboard", to: "dashboard#index"
  get "analytics", to: "dashboard#analytics"

  # Admin panel
  namespace :admin do
    root "dashboard#index"
    get "dashboard", to: "dashboard#index"

    resources :workflows do
      member do
        post :execute
        get :results
      end
      collection do
        get :service_info
      end
    end

    resources :threat_feeds do
      member do
        post :fetch
        post :toggle
      end
      collection do
        post :bulk_refresh
      end
    end
  end

  # abuse.ch integration (URLhaus & Feodo Tracker)
  get "abuse_ch", to: "abuse_ch#index", as: :abuse_ch_index
  get "abuse_ch/urls", to: "abuse_ch#recent_urls", as: :abuse_ch_recent_urls
  get "abuse_ch/payloads", to: "abuse_ch#recent_payloads", as: :abuse_ch_recent_payloads
  get "abuse_ch/feodo", to: "abuse_ch#feodo_tracker", as: :abuse_ch_feodo_tracker
  post "abuse_ch/refresh_feodo", to: "abuse_ch#refresh_feodo", as: :abuse_ch_refresh_feodo

  namespace :api do
    namespace :v1 do
      post "auth/login", to: "auth#login"
      post "auth/regenerate_token", to: "auth#regenerate_token"

      resources :threats
      resources :indicators do
        collection do
          get :search
        end
      end
      resources :vulnerabilities
      resources :mitre_attacks
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
