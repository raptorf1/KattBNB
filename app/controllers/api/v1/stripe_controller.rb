class Api::V1::StripeController < ApplicationController
  
  before_action :authenticate_api_v1_user!, only: [:index]

  def index
    profile = HostProfile.where(id: params[:host_profile_id])
    Stripe.api_key = ENV['OFFICIAL'] == 'yes' ? Rails.application.credentials.STRIPE_API_KEY_PROD : Rails.application.credentials.STRIPE_API_KEY_DEV
    if params[:occasion] == 'retrieve' && current_api_v1_user.id == profile[0].user_id
      stripe_account = profile[0].stripe_account_id
      if stripe_account
        begin
          response = Stripe::Account.retrieve(stripe_account)
          render json: { payouts_enabled: response.payouts_enabled, requirements: response.requirements }, status: 200
        rescue Stripe::StripeError
          render json: { error: I18n.t('controllers.reusable.stripe_error') }, status: 555
        end
      else
        render json: { message: 'No account' }, status: 200
      end
    elsif params[:occasion] == 'login_link' && current_api_v1_user.id == profile[0].user_id
      stripe_account = profile[0].stripe_account_id
      if stripe_account
        begin
          response = Stripe::Account.create_login_link(stripe_account)
          render json: { url: response.url }, status: 200
        rescue Stripe::StripeError
          render json: { error: I18n.t('controllers.reusable.stripe_error') }, status: 555
        end
      end
    elsif params[:occasion] == 'create_payment_intent'
      stripe_amount = params[:amount]
      if stripe_amount.include? '.'
        stripe_amount = stripe_amount.delete '.'
      else
        stripe_amount = params[:amount] + '00'
      end
      begin
        intent = Stripe::PaymentIntent.create({
          amount: stripe_amount,
          currency: params[:currency],
          receipt_email: current_api_v1_user.email,
          capture_method: 'manual'
        })
        render json: { intent_id: intent.client_secret }, status: 200
      rescue Stripe::StripeError
        render json: { error: I18n.t('controllers.reusable.stripe_error') }, status: 555
      end
    else
      render json: { error: I18n.t('controllers.reusable.update_error') }, status: 422
    end
  end

end
