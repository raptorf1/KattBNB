class Api::V1::StripeActions::UpdatePaymentIntentController < ApplicationController
  before_action :authenticate_api_v1_user!, only: [:index]

  def index
    Stripe.api_key = StripeService.get_api_key

    payment_intent_id = params[:payment_intent_id].split("_secret")[0]
    begin
      Stripe::PaymentIntent.update(
        payment_intent_id,
        {
          metadata: {
            number_of_cats: params[:number_of_cats],
            message: params[:message],
            dates: limit_dates_calulator(Rails.env.test? ? params[:dates] : params[:dates].join(",")),
            host_nickname: params[:host_nickname],
            price_per_day: params[:price_per_day],
            price_total: params[:price_total],
            user_id: params[:user_id],
            payment_intent_id: payment_intent_id
          }
        }
      )
      render json: { message: I18n.t("controllers.reusable.update_success") }, status: 200
    rescue Stripe::StripeError => error
      render json: { errors: [error.error.message] }, status: 400
    end
  end

  private

  def limit_dates_calulator(date_obj_as_string)
    if date_obj_as_string.length >= 490
      stripe_500_limit_dates = []
      dates_to_array = date_obj_as_string.split(",").map(&:to_i)
      stripe_500_limit_dates.push(dates_to_array.first, dates_to_array.last)
      return stripe_500_limit_dates.join(",")
    end
    date_obj_as_string
  end
end
