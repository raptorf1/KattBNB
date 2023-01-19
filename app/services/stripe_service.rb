module StripeService
  def self.get_api_key()
    if ENV["OFFICIAL"] == "yes"
      Rails.application.credentials.STRIPE_API_KEY_PROD
    else
      Rails.application.credentials.STRIPE_API_KEY_DEV
    end
  end

  def self.get_webhook_endpoint_secret()
    if ENV["OFFICIAL"] == "yes"
      Rails.application.credentials.STRIPE_WEBHOOK_SIGN_PROD
    else
      Rails.application.credentials.STRIPE_WEBHOOK_SIGN_TEST
    end
  end

  def self.cancel_payment_intent(payment_intent_id)
    Stripe.api_key = get_api_key

    begin
      Stripe::PaymentIntent.cancel(payment_intent_id)
    rescue Stripe::StripeError => error
      print error
      StripeMailer.delay(queue: "stripe_email_notifications").notify_orphan_payment_intent_to_cancel(payment_intent_id)
    end
  end
end
