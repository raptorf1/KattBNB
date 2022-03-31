namespace :bookings do
  desc 'Cancel all pending bookings after 3 days'
  task cancel_after_3_days: :environment do
    Stripe.api_key =
      if ENV['OFFICIAL'] == 'yes'
        Rails.application.credentials.STRIPE_API_KEY_PROD
      else
        Rails.application.credentials.STRIPE_API_KEY_DEV
      end
    pending_bookings = Booking.where(status: 'pending')
    cancelled_bookings = []
    pending_bookings.each do |booking|
      if ((Time.current - booking.created_at) / 1.hour).round > 72
        user = User.where(id: booking.user_id)
        host = User.where(nickname: booking.host_nickname)
        booking.update_column(:status, 'canceled')
        booking.update_column(:host_message, 'cancelled by system')
        begin
          Stripe::PaymentIntent.cancel(booking.payment_intent_id)
        rescue Stripe::StripeError
          StripeMailer
            .delay(queue: 'stripe_email_notifications')
            .notify_orphan_payment_intent_to_cancel(booking.payment_intent_id)
        end
        cancelled_bookings.push(booking)
        BookingsMailer
          .delay(queue: 'bookings_email_notifications')
          .notify_user_cancelled_booking(host[0], booking, user[0])
        BookingsMailer
          .delay(queue: 'bookings_email_notifications')
          .notify_host_cancelled_booking(host[0], booking, user[0])
      end
    end
    puts "#{cancelled_bookings.length} pending booking(s) succesfully cancelled!"
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
    bookings_to_pay = Booking.where(status: 'accepted', paid: false)
    bookings_to_pay.each do |booking|
      if booking.dates.last < now_epoch_javascript
        host = User.where(nickname: booking.host_nickname)
        profile = HostProfile.where(user_id: host[0].id)
        begin
          Stripe::Transfer.create(
            {
              amount: (booking.price_total * 100).to_i,
              currency: 'sek',
              destination: profile[0].stripe_account_id,
              metadata: {
                booking_id: booking.id
              }
            }
          )
          booking.update(paid: true)
          if ENV['OFFICIAL'] == 'yes'
            ReportsMailer.delay(queue: 'financial_reports_email_notifications').bookings_revenue_and_vat(booking)
          else
            (puts 'A report email was sent!')
          end
        rescue Stripe::StripeError
          StripeMailer
            .delay(queue: 'stripe_email_notifications')
            .notify_stripe_webhook_error("Payment to host for booking id #{booking.id} failed")
        end
      end
    end
  end

  # When we reach this point on refactoring the code, we can delete this task completely.
  # It was run once when we migrated the database, adding the host_profile_id field in the Booking model.
  # 'host-profiles-caching' branch and PR.

  desc 'Apply host profile id to accepted bookings'
  task apply_host_profile_id: :environment do
    accepted_bookings = Booking.where(status: 'accepted')
    accepted_bookings.each do |accepted_booking|
      host = User.where(nickname: accepted_booking.host_nickname)
      if host.length == 1
        profile = HostProfile.where(user_id: host[0].id)
        accepted_booking.update(host_profile_id: profile[0].id)
        puts "Accepted booking with id #{accepted_booking.id} successfully updated"
      end
    end
  end
end
