class Api::V1::StripeActions::ReceiveWebhooksController < ApplicationController
  def create
    render json: { message: "Success!" }, status: 200
    Stripe.api_key = StripeService.get_api_key
    endpoint_secret = StripeService.get_webhook_endpoint_secret
    payload = request.body.read
    sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
    event = nil
    begin
      Rails.env.test? ?
        event = Stripe::Event.construct_from(JSON.parse(payload, symbolize_names: true)) :
        event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
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
    rescue JSON::ParserError
      StripeMailer.delay(queue: "stripe_email_notifications").notify_stripe_webhook_error("Webhook JSON Parse Error")
    rescue Stripe::SignatureVerificationError
      StripeMailer.delay(queue: "stripe_email_notifications").notify_stripe_webhook_error(
        "Webhook Signature Verification Error"
      )
    rescue Stripe::StripeError
      StripeMailer.delay(queue: "stripe_email_notifications").notify_stripe_webhook_error(
        "General Stripe Webhook Error"
      )
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
      !Rails.env.test? && sleep(10)
      booking_exists = Booking.find_by(payment_intent_id: payment_intent)
      if booking_exists.nil?
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
        if booking_to_create.persisted?
          host = User.find_by(nickname: host_nickname)
          if !host.nil?
            user = User.find(user_id)
            if BookingService.validate_booking_dates_on_creation(host_nickname, dates)
              BookingsMailer.delay(queue: "bookings_email_notifications").notify_host_create_booking(
                host,
                booking_to_create,
                user
              )
            else
              StripeService.webhook_cancel_payment_intent_and_delete_booking(payment_intent, booking_to_create.id)
            end
          else
            StripeService.webhook_cancel_payment_intent_and_delete_booking(payment_intent, booking_to_create.id)
          end
        else
          StripeService.webhook_cancel_payment_intent_and_delete_booking(payment_intent, nil)
        end
      else
        print "Booking already exists! Show me the moneyyyyy!"
      end
    end
  end
end
