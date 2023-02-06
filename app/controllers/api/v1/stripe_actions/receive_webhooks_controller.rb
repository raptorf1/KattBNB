class Api::V1::StripeActions::ReceiveWebhooksController < ApplicationController
  def create
    Stripe.api_key = StripeService.get_api_key
    endpoint_secret = StripeService.get_webhook_endpoint_secret
    payload = request.body.read
    sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
    event = nil
    begin
      Rails.env.test? ?
        event = Stripe::Event.construct_from(JSON.parse(payload, symbolize_names: true)) :
        event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
    rescue JSON::ParserError => error
      print error
      StripeMailer.delay(queue: "stripe_email_notifications").notify_stripe_webhook_error("Webhook JSON Parse Error")
      render json: { error: error }, status: 400 and return
    rescue Stripe::SignatureVerificationError => error
      print error
      StripeMailer.delay(queue: "stripe_email_notifications").notify_stripe_webhook_error(
        "Webhook Signature Verification Error"
      )
      render json: { error: error }, status: 400 and return
    rescue Stripe::StripeError => error
      print error
      StripeMailer.delay(queue: "stripe_email_notifications").notify_stripe_webhook_error(
        "General Stripe Webhook Error"
      )
      render json: { error: error }, status: 400 and return
    end
    render json: { message: "Success!" }, status: 200
    case event.type
    when "charge.succeeded"
      payment_intent = event.data.object.payment_intent
      number_of_cats = event.data.object.metadata.number_of_cats
      message = event.data.object.metadata.message
      host_nickname = event.data.object.metadata.host_nickname
      price_per_day = event.data.object.metadata.price_per_day
      price_total = event.data.object.metadata.price_total
      user_id = event.data.object.metadata.user_id
      Delayed::Job.enqueue CreateBookingForDummies.new(
                             payment_intent,
                             number_of_cats,
                             message,
                             DateService.handle_dates_in_stripe_webhook(event.data.object.metadata.dates),
                             host_nickname,
                             price_per_day,
                             price_total,
                             user_id
                           )
    when "charge.dispute.created", "issuing_dispute.created", "radar.early_fraud_warning.created"
      StripeMailer.delay(queue: "stripe_email_notifications").notify_stripe_webhook_dispute_fraud
    else
      print "Unhandled event type: #{event.type}. Why are we receiving this again???"
    end
  end

  class CreateBookingForDummies < Struct.new(
    :payment_intent,
    :number_of_cats,
    :message,
    :dates,
    :host_nickname,
    :price_per_day,
    :price_total,
    :user_id
  )
    def perform
      !Rails.env.test? && sleep(3)

      booking_exists = Booking.find_by(payment_intent_id: payment_intent)
      if !booking_exists.nil?
        print "Booking already exists! Show me the moneyyyyy!"
        return
      end

      host = User.find_by(nickname: host_nickname)
      if host.nil?
        StripeService.cancel_payment_intent(payment_intent)
        return
      end

      if !BookingService.validate_dates(host_nickname, dates)
        StripeService.cancel_payment_intent(payment_intent)
        return
      end

      booking_to_create =
        Booking.create(
          payment_intent_id: payment_intent,
          number_of_cats: number_of_cats,
          message: message,
          dates: dates,
          host_nickname: host_nickname,
          price_per_day: price_per_day,
          price_total: price_total,
          user_id: user_id
        )
      if !booking_to_create.persisted?
        StripeService.cancel_payment_intent(payment_intent)
        return
      end

      user = User.find(user_id)
      BookingsMailer.delay(queue: "bookings_email_notifications").notify_host_create_booking(
        host,
        booking_to_create,
        user
      )
    end
  end
end
