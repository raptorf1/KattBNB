namespace :bookings do
  desc 'Cancel all pending bookings after 3 days'
  task cancel_after_3_days: :environment do
    Stripe.api_key =
      if ENV['OFFICIAL'] == 'yes'
        Rails.application.credentials.STRIPE_API_KEY_PROD
      else
        Rails.application.credentials.STRIPE_API_KEY_DEV
      end
    Booking
      .where(status: 'pending')
      .each do |booking|
        if ((Time.current - booking.created_at) / 1.hour).round > 72
          user = User.find(booking.user_id)
          host = User.find_by(nickname: booking.host_nickname)
          booking.update_column(:status, 'canceled')
          booking.update_column(:host_message, 'cancelled by system')
          begin
            Stripe::PaymentIntent.cancel(booking.payment_intent_id)
          rescue Stripe::StripeError
            StripeMailer
              .delay(queue: 'stripe_email_notifications')
              .notify_orphan_payment_intent_to_cancel(booking.payment_intent_id)
          end
          print "Pending booking with id #{booking.id} succesfully cancelled!"
          BookingsMailer.delay(queue: 'bookings_email_notifications').notify_user_cancelled_booking(host, booking, user)
          BookingsMailer.delay(queue: 'bookings_email_notifications').notify_host_cancelled_booking(host, booking, user)
        end
      end
  end

  desc 'Pay the host'
  task pay_the_host: :environment do
    Stripe.api_key =
      if ENV['OFFICIAL'] == 'yes'
        Rails.application.credentials.STRIPE_API_KEY_PROD
      else
        Rails.application.credentials.STRIPE_API_KEY_DEV
      end
    now = DateTime.new(Time.now.year, Time.now.month, Time.now.day, 0, 0, 0, 0)
    now_epoch_javascript = (now.to_f * 1000).to_i
    Booking
      .where(status: 'accepted', paid: false)
      .each do |booking|
        if booking.dates.last < now_epoch_javascript
          host = User.find_by(nickname: booking.host_nickname)
          profile = HostProfile.find_by(user_id: host.id)
          begin
            Stripe::Transfer.create(
              {
                amount: (booking.price_total * 100).to_i,
                currency: 'sek',
                destination: profile.stripe_account_id,
                metadata: {
                  booking_id: booking.id
                }
              }
            )
            booking.update(paid: true)
            if ENV['OFFICIAL'] == 'yes'
              ReportsMailer.delay(queue: 'financial_reports_email_notifications').bookings_revenue_and_vat(booking)
            else
              print "A report email was sent! Booking with id #{booking.id} successfully paid!"
            end
          rescue Stripe::StripeError
            StripeMailer
              .delay(queue: 'stripe_email_notifications')
              .notify_stripe_webhook_error("Payment to host for booking id #{booking.id} failed")
          end
        end
      end
  end
end
