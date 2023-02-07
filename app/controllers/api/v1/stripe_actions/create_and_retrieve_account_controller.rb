class Api::V1::StripeActions::CreateAndRetrieveAccountController < ApplicationController
  before_action :authenticate_api_v1_user!, only: [:index]

  def index
    Stripe.api_key = StripeService.get_api_key

    current_api_v1_user.host_profile.nil? &&
      (render json: { errors: [I18n.t("controllers.reusable.no_host_profile")] }, status: 400) and return

    profile = HostProfile.find_by(user_id: current_api_v1_user.id)
    begin
      response = Stripe::OAuth.token({ grant_type: "authorization_code", code: params[:code] })
    rescue Stripe::OAuth::InvalidGrantError
      render json: { errors: [I18n.t("controllers.host_profiles.stripe_create_error")] }, status: 400
    rescue Stripe::StripeError
      render json: { errors: [I18n.t("controllers.host_profiles.stripe_create_error")] }, status: 400
    else
      profile.update(stripe_account_id: response.stripe_user_id)
      render json: {
               message: I18n.t("controllers.host_profiles.update_success"),
               id: response.stripe_user_id
             },
             status: 200
    end
  end
end
