class Api::V1::StripeController < ApplicationController
  
  before_action :authenticate_api_v1_user!, only: [:index]

  def index
    profile = HostProfile.where(id: params[:host_profile_id])
    stripe_account = profile[0].stripe_account_id
    if current_api_v1_user.id == profile[0].user_id && params[:occasion] == 'retrieve'
      if stripe_account
        begin
          Stripe.api_key = ENV['OFFICIAL'] == 'yes' ? Rails.application.credentials.STRIPE_API_KEY_PROD : Rails.application.credentials.STRIPE_API_KEY_DEV
          response = Stripe::Account.retrieve(stripe_account)
          render json: { payouts_enabled: response.payouts_enabled, requirements: response.requirements }, status: 200
        rescue Stripe::StripeError
          render json: { error: I18n.t('controllers.reusable.stripe_error') }, status: 500
        end
      else
        render json: { message: 'No account' }, status: 200
      end
    elsif current_api_v1_user.id == profile[0].user_id && params[:occasion] == 'login_link'
      # do some stuff
    else
      render json: { error: I18n.t('controllers.reusable.update_error') }, status: 422
    end
  end

end
