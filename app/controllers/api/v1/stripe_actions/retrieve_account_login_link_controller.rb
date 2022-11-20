class Api::V1::StripeActions::RetrieveAccountLoginLinkController < ApplicationController
  before_action :authenticate_api_v1_user!, only: [:index]

  def index
    Stripe.api_key = StripeService.get_api_key

    current_api_v1_user.host_profile.nil? &&
      (render json: { errors: [I18n.t("controllers.reusable.no_host_profile")] }, status: 400) and return

    !current_api_v1_user.host_profile.stripe_account_id.present? &&
      (render json: { message: I18n.t("controllers.reusable.no_stripe_account") }, status: 200) and return

    begin
      response = Stripe::Account.create_login_link(current_api_v1_user.host_profile.stripe_account_id)
      render json: { url: response.url }, status: 200
    rescue Stripe::StripeError => error
      render json: { errors: [error.error.message] }, status: 400
    end
  end
end
