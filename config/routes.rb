Rails.application.routes.draw do
  namespace :api do
    namespace :v0 do
      resources :pings, only: [:index], constraints: { format: "json" }
    end

    scope "(:locale)", locale: /#{I18n.available_locales.join("|")}/ do
      namespace :v1 do
        mount_devise_token_auth_for "User", at: "auth", skip: [:omniauth_callbacks]
        mount ActionCable.server => "/cable/conversation(/:conversation_id/)"
        resources :users, only: %i[show update]
        resources :contactus, only: [:index]
        resources :host_profiles, only: %i[index show create update]
        resources :bookings, only: %i[index create update]
        resources :conversations, only: %i[create index show update]
        resources :reviews, only: %i[index show create update]
        resources :stripe, only: %i[index create]

        namespace :random_reviews do
          resources :reviews, only: [:index]
        end

        namespace :stripe_actions do
          resources :retrieve_account_details, only: [:index]
          resources :retrieve_account_login_link, only: [:index]
          resources :create_payment_intent, only: [:index]
          resources :update_payment_intent, only: [:index]
          resources :delete_account, only: [:index]
        end
      end
    end
  end
end
