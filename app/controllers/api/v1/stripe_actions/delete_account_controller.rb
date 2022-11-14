class Api::V1::StripeActions::DeleteAccountController < ApplicationController
  before_action :authenticate_api_v1_user!, only: [:index]

  def index
    Stripe.api_key = StripeService.get_api_key

    current_api_v1_user.host_profile.nil? &&
      (render json: { errors: [I18n.t("controllers.reusable.no_host_profile")] }, status: 400) and return

    !current_api_v1_user.host_profile.stripe_account_id.present? &&
      (render json: { message: I18n.t("controllers.reusable.no_stripe_account") }, status: 200) and return

    begin
      Stripe::Account.delete(current_api_v1_user.host_profile.stripe_account_id)
      render json: { message: I18n.t("controllers.conversations.update_success") }, status: 200
    rescue Stripe::StripeError => error
      render json: { errors: [error.error.code] }, status: 400
    end
  end
end
