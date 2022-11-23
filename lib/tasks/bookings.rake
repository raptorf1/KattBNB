namespace :bookings do
  desc "Cancel all pending bookings after 3 days"
  task cancel_after_3_days: :environment do
    Stripe.api_key = StripeService.get_api_key
    all_pending_bookings = Booking.where(status: "pending")
    if !all_pending_bookings.empty?
      all_pending_bookings.each do |booking|
        if ((Time.current - booking.created_at) / 1.hour).round > 72
          user = User.find(booking.user_id)
          host = User.find_by(nickname: booking.host_nickname)
          booking.update_column(:status, "canceled")
          booking.update_column(:host_message, "cancelled by system")
          begin
            Stripe::PaymentIntent.cancel(booking.payment_intent_id)
          rescue Stripe::StripeError => error
            print error
            StripeMailer.delay(queue: "stripe_email_notifications").notify_orphan_payment_intent_to_cancel(
              booking.payment_intent_id
            )
          end
          print "Pending booking with id #{booking.id} succesfully cancelled!"
          BookingsMailer.delay(queue: "bookings_email_notifications").notify_user_cancelled_booking(host, booking, user)
          BookingsMailer.delay(queue: "bookings_email_notifications").notify_host_cancelled_booking(host, booking, user)
        end
      end
    end
  end

  desc "Pay the host"
  task pay_the_host: :environment do
    Stripe.api_key = StripeService.get_api_key
    unpaid_bookings = Booking.where(status: "accepted", paid: false)
    if !unpaid_bookings.empty?
      unpaid_bookings.each do |booking|
        if booking.dates.last < DateService.get_js_epoch
          host = User.find_by(nickname: booking.host_nickname)
          profile = HostProfile.find_by(user_id: host.id)
          begin
            Stripe::Transfer.create(
              {
                amount: (booking.price_total * 100).to_i,
                currency: "sek",
                destination: profile.stripe_account_id,
                metadata: {
                  booking_id: booking.id
                }
              }
            )
            booking.update(paid: true)
            if ENV["OFFICIAL"] == "yes"
              ReportsMailer.delay(queue: "financial_reports_email_notifications").bookings_revenue_and_vat(booking)
            else
              print "A report email was sent! Booking with id #{booking.id} successfully paid!"
            end
          rescue Stripe::StripeError => error
            print error
            StripeMailer.delay(queue: "stripe_email_notifications").notify_stripe_webhook_error(
              "Payment to host for booking id #{booking.id} failed"
            )
          end
        end
      end
    end
  end
end
