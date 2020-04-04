namespace :bookings do
  desc 'Cancel all pending bookings after 3 days'
  task cancel_after_3_days: :environment do
    pending_bookings = Booking.where(status: 'pending')
    cancelled_bookings = []
    pending_bookings.each do |booking|
      ##if ((Time.current - booking.created_at)/1.hour).round > 72
        user = User.where(id: booking.user_id)
        host = User.where(nickname: booking.host_nickname)
        profile = HostProfile.where(user_id: host[0].id)
        booking.update_column(:status, 'canceled')
        booking.update_column(:host_message, 'cancelled by system')
        cancelled_bookings.push(booking)
        new_availability = (profile[0].availability + booking.dates).sort
        profile.update(availability: new_availability)
        BookingsMailer.notify_user_cancelled_booking(host[0], booking, user[0]).deliver
        BookingsMailer.notify_host_cancelled_booking(host[0], booking, user[0]).deliver
      ##end
    end
    puts "#{cancelled_bookings.length} pending booking(s) succesfully cancelled!"
  end
end
