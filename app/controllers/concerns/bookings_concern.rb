module BookingsConcern
  extend ActiveSupport::Concern

  included do
    helper_method :find_host_bookings
    helper_method :cancel_payment_intent
  end

  def find_host_bookings(host_profile_id, id_number)
    now = DateTime.new(Time.now.year, Time.now.month, Time.now.day, 0, 0, 0, 0)
    now_epoch_javascript = (now.to_f * 1000).to_i
    host_booked_dates = []
    host_bookings = Booking.cached_by_host_profile_id(host_profile_id)
    host_bookings.each do |host_booking|
      if id_number > 0
        if host_booking.id != id_number && host_booking.dates.last > now_epoch_javascript
          host_booked_dates.push(host_booking.dates)
        end
      else
        next unless host_booking.dates.last > now_epoch_javascript
        host_booked_dates.push(host_booking.dates)
      end
    end
    host_booked_dates.flatten.sort
  end

  def cancel_payment_intent(booking_payment_intent_id)
    Stripe.api_key =
      if ENV["OFFICIAL"] == "yes"
        Rails.application.credentials.STRIPE_API_KEY_PROD
      else
        Rails.application.credentials.STRIPE_API_KEY_DEV
      end
    begin
      Stripe::PaymentIntent.cancel(booking_payment_intent_id)
    rescue Stripe::StripeError
      StripeMailer.delay(queue: "stripe_email_notifications").notify_orphan_payment_intent_to_cancel(
        booking_payment_intent_id
      )
    end
  end
end
