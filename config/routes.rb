Rails.application.routes.draw do

  namespace :api do
    namespace :v0 do
      resources :pings, only: [:index], constraints: { format: 'json' }
    end

    scope "(:locale)", locale: /#{I18n.available_locales.join("|")}/ do
      namespace :v1 do
        mount_devise_token_auth_for 'User', at: 'auth', skip: [:omniauth_callbacks]
        mount ActionCable.server => '/cable/conversation(/:conversation_id/)'
        resources :users, only: [:update]
        resources :host_profiles, only: [:index, :show, :create, :update]
        resources :bookings, only: [:index, :create, :update]
        resources :conversations, only: [:create, :index, :show, :update]
        resources :reviews, only: [:show, :create]
      end
    end
  end

end
