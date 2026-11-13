Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  get "sitemap.xml" => "sitemaps#show", as: :sitemap, defaults: { format: :xml }
  get "robots.txt" => "robots#show", as: :robots, defaults: { format: :text }

  devise_for :users, only: :omniauth_callbacks, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }

  namespace :webhooks do
    resource :stripe, only: :create
  end

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resource :session, only: %i[create destroy]
      resource :registration, only: :create
      resource :me, only: %i[show update], controller: "me"
      resources :countries, only: :index
      resources :categories, only: %i[index show]
      resources :collections, only: %i[index show]
      resources :listings, only: %i[index show create update destroy] do
        resource :favorite, only: %i[create destroy]
        resource :submission, only: :create
      end
      resources :favorites, only: :index
      resources :sellers, only: :show
      resources :conversations, only: %i[index show create] do
        resources :messages, only: :create
      end
      resources :offers, only: %i[create update]
      resources :orders, only: %i[index show]
      resources :notifications, only: %i[index update]
      resources :saved_searches, only: %i[index create destroy]
    end
  end

  scope "(:locale)", locale: /es|en|fr|de|it|pt/ do
    devise_for :users, skip: :omniauth_callbacks, controllers: { registrations: "users/registrations", sessions: "users/sessions" }

    root "home#show"

    resources :categories, only: :show, path: "c"
    resources :collections, only: :show, path: "collections"
    resources :listings do
      resource :favorite, only: %i[create destroy]
      resource :submission, only: :create, module: :listings
      resource :pause, only: %i[create destroy], module: :listings
      resources :offers, only: %i[new create], module: :listings
    end
    resources :offers, only: :update
    resources :stores, only: :show do
      resource :follow, only: %i[create destroy], module: :stores
      resources :reviews, only: :index, module: :stores
    end
    resource :pc_finder, only: :show, path: "pc-finder"

    resources :favorites, only: :index, path: "wishlist"
    resources :saved_searches, only: %i[index create update destroy]
    resources :notifications, only: %i[index update]
    resource :notification_readings, only: :create
    resources :conversations, only: %i[index show create] do
      resources :messages, only: :create
    end
    resources :blocks, only: %i[index create destroy]
    resources :reports, only: %i[new create]

    resource :cart, only: :show
    resources :cart_items, only: %i[create update destroy]
    resource :checkout, only: %i[show create]
    resource :checkout_confirmation, only: :show
    resources :orders, only: %i[index show], param: :number do
      scope module: :orders do
        resource :shipment, only: :create
        resource :delivery, only: :create
        resource :acceptance, only: :create
        resource :cancellation, only: :create
        resource :dispute, only: :create
        resource :review, only: %i[new create]
      end
    end

    namespace :account do
      resource :profile, only: %i[edit update]
      resource :store, only: %i[edit update]
      resource :notification_settings, only: %i[edit update]
      resources :addresses, except: :show
      resource :data_export, only: :show
      resource :deletion, only: %i[new create]
    end

    namespace :seller do
      resource :dashboard, only: :show
      resources :listings, only: :index
      resources :sales, only: :index
      resources :discount_codes, only: %i[index create update destroy]
      resource :vacation, only: :update
      resources :promotions, only: %i[new create]
      resources :review_replies, only: :update
    end

    resources :buyback_requests, only: %i[index new create], path: "sell-to-us"
    resources :support_tickets, only: %i[new create], path: "support"
    resources :newsletter_subscriptions, only: %i[create show update destroy], param: :token, path: "newsletter"
    resource :country_preference, only: :update
    resources :pages, only: :show, path: "p"
    resources :legal_pages, only: :show, path: "legal"
    get "trust-and-safety" => "pages#show", defaults: { id: "trust" }, as: :trust
    get "sell" => "pages#show", defaults: { id: "sell" }, as: :sell_info
    get "deals" => "listings#index", defaults: { on_sale: "1" }, as: :deals

    namespace :admin do
      root "dashboards#show"
      resources :listings, only: %i[index show edit update destroy] do
        resource :approval, only: :create, module: :listings
        resource :rejection, only: :create, module: :listings
      end
      resources :listing_bulk_actions, only: :create
      resources :users, only: %i[index show edit update]
      resources :orders, only: %i[index show update]
      resources :categories
      resources :filter_definitions
      resources :collections, except: :show
      resources :games, except: :show
      resources :countries, only: %i[index edit update]
      resource :settings, only: %i[show update]
      resources :legal_pages, except: :show
      resources :reports, only: %i[index show update]
      resources :reviews, only: %i[index update]
      resources :support_tickets, only: %i[index show update]
      resources :newsletter_subscriptions, only: %i[index destroy]
      resources :buyback_requests, only: %i[index update]
      resources :promotions, only: %i[index update]
      resources :conversations, only: %i[index show]
      resources :audit_logs, only: :index
    end
  end
end
