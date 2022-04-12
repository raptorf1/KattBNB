class Api::V1::StripeActions::RetrieveAccountLoginLinkController < ApplicationController
  before_action :authenticate_api_v1_user!, only: [:index]

  def index
    profile = HostProfile.find(params[:host_profile_id])
    Stripe.api_key = StripeService.get_api_key
    if current_api_v1_user.id == profile.user_id
      stripe_account = profile.stripe_account_id
      if stripe_account.present?
        begin
          response = Stripe::Account.create_login_link(stripe_account)
          render json: { url: response.url }, status: 200
        rescue Stripe::StripeError
          render json: { error: I18n.t('controllers.reusable.stripe_error') }, status: 555
        end
      end
    else
      render json: { error: I18n.t('controllers.reusable.update_error') }, status: 422
    end
  end
end
