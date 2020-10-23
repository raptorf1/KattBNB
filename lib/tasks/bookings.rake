namespace :bookings do
  desc 'Cancel all pending bookings after 3 days'
  task cancel_after_3_days: :environment do
    Stripe.api_key = ENV['OFFICIAL'] == 'yes' ? Rails.application.credentials.STRIPE_API_KEY_PROD : Rails.application.credentials.STRIPE_API_KEY_DEV
    pending_bookings = Booking.where(status: 'pending')
    cancelled_bookings = []
    pending_bookings.each do |booking|
      if ((Time.current - booking.created_at)/1.hour).round > 72
        user = User.where(id: booking.user_id)
        host = User.where(nickname: booking.host_nickname)
        profile = HostProfile.where(user_id: host[0].id)
        booking.update_column(:status, 'canceled')
        booking.update_column(:host_message, 'cancelled by system')
        begin
          Stripe::PaymentIntent.cancel(booking.payment_intent_id)
        rescue Stripe::StripeError
          StripeMailer.delay(:queue => 'stripe_email_notifications').notify_orphan_payment_intent_to_cancel(booking.payment_intent_id)
        end
        cancelled_bookings.push(booking)
        new_availability = (profile[0].availability + booking.dates).sort
        profile.update(availability: new_availability)
        BookingsMailer.delay(:queue => 'bookings_email_notifications').notify_user_cancelled_booking(host[0], booking, user[0])
        BookingsMailer.delay(:queue => 'bookings_email_notifications').notify_host_cancelled_booking(host[0], booking, user[0])
      end
    end
    puts "#{cancelled_bookings.length} pending booking(s) succesfully cancelled!"
  end
end
