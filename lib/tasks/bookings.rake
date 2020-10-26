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

  desc 'Pay the host'
  task pay_the_host: :environment do
    Stripe.api_key = ENV['OFFICIAL'] == 'yes' ? Rails.application.credentials.STRIPE_API_KEY_PROD : Rails.application.credentials.STRIPE_API_KEY_DEV
    now = DateTime.new(Time.now.year, Time.now.month, Time.now.day, 0, 0, 0, 0)
    now_epoch_javascript = (now.to_f * 1000).to_i
    bookings_to_pay = Booking.where(status: 'accepted', paid: false)
    bookings_to_pay.each do |booking|
      if booking.dates.last < now_epoch_javascript
        host = User.find(nickname: booking.host_nickname)
        profile = HostProfile.find(user_id: host.id)
        begin
          Stripe::Transfer.create({
            amount: (booking.price_total*100).to_i,
            currency: 'sek',
            destination: profile.stripe_account_id,
          })
        rescue Stripe::StripeError
          puts 'Stripe error :P'
        end
      end
    end
  end

end
