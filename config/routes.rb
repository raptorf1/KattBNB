Rails.application.routes.draw do

  namespace :api do
    namespace :v0 do
      resources :pings, only: [:index], constraints: { format: 'json' }
    end

    namespace :v1 do
      mount_devise_token_auth_for 'User', at: 'auth', skip: [:omniauth_callbacks]
      resources :host_profiles, only: [:index, :show, :create, :destroy, :update]
      resources :bookings, only: [:index, :create, :update, :destroy]
      resources :conversations, only: [:create]
    end
  end
end
