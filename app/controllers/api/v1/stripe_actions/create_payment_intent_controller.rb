class Api::V1::StripeActions::CreatePaymentIntentController < ApplicationController
  before_action :authenticate_api_v1_user!, only: [:index]

  def index
    Stripe.api_key = StripeService.get_api_key

    api_amount = calculate_price(params[:inDate], params[:outDate], params[:cats], params[:host]).to_f
    client_amount = ("%.2f" % params[:amount]).to_f

    if api_amount - client_amount <= 1 && api_amount - client_amount >= -1
      stripe_amount = calculate_stripe_amount(params[:amount])
      begin
        intent =
          Stripe::PaymentIntent.create(
            {
              amount: stripe_amount,
              currency: params[:currency].nil? ? "sek" : params[:currency],
              receipt_email: current_api_v1_user.email,
              capture_method: "manual"
            }
          )
        render json: { intent_id: intent.client_secret }, status: 200
      rescue Stripe::StripeError => error
        render json: { errors: [error.error.message] }, status: 400
      end
    else
      render json: {
               errors: [I18n.t("controllers.stripe_actions.create_payment_intent_calculate_amount_error")]
             },
             status: 400
    end
  end

  private

  def calculate_price(in_date, out_date, cats, host)
    user = User.find_by(nickname: host)
    if !user.nil?
      host_profile = HostProfile.find_by(user_id: user.id)
      if !host_profile.nil?
        price = host_profile.price_per_day_1_cat + ((cats.to_i - 1) * host_profile.supplement_price_per_cat_per_day)
        total = price * (((out_date.to_i - in_date.to_i) / 86_400_000) + 1)
        final_charge = PriceService.calculate_kattbnb_charge(total)
        "%.2f" % final_charge
      else
        "%.2f" % 0
      end
    else
      "%.2f" % 0
    end
  end

  def calculate_stripe_amount(number)
    if number.include? "."
      number.delete "."
    else
      number + "00"
    end
  end
end
