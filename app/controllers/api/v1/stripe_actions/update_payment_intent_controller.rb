class Api::V1::StripeActions::UpdatePaymentIntentController < ApplicationController
  before_action :authenticate_api_v1_user!, only: [:index]

  def index
    Stripe.api_key = StripeService.get_api_key
    payment_intent_id = params[:payment_intent_id].split("_secret")[0]
    stripe_500_limit_dates = limit_dates_calulator(params[:dates])
    begin
      Stripe::PaymentIntent.update(
        payment_intent_id,
        {
          metadata: {
            number_of_cats: params[:number_of_cats],
            message: params[:message],
            dates: stripe_500_limit_dates.length > 0 ? stripe_500_limit_dates.join(",") : params[:dates],
            host_nickname: params[:host_nickname],
            price_per_day: params[:price_per_day],
            price_total: params[:price_total],
            user_id: params[:user_id],
            payment_intent_id: payment_intent_id
          }
        }
      )
      render json: { message: "Payment Intent updated!" }, status: 200
    rescue Stripe::StripeError
      render json: { error: I18n.t("controllers.reusable.stripe_error") }, status: 555
    end
  end

  private

  def limit_dates_calulator(date_obj)
    stripe_500_limit_dates = []
    if date_obj.length >= 490
      dates_to_array = date_obj.split(",").map(&:to_i)
      stripe_500_limit_dates.push(dates_to_array.first, dates_to_array.last)
    end
    stripe_500_limit_dates
  end
end
