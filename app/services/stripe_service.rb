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

  def self.webhook_cancel_payment_intent_and_delete_booking(payment_intent_id, booking_id)
    Stripe.api_key = get_api_key

    begin
      Stripe::PaymentIntent.cancel(payment_intent_id)
    rescue Stripe::StripeError => error
      print error
      StripeMailer.delay(queue: "stripe_email_notifications").notify_orphan_payment_intent_to_cancel(payment_intent_id)
    end

    !booking_id.nil? && Booking.destroy(booking_id)
  end
end
