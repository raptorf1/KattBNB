namespace :bookings do
  desc 'Cancel all pending bookings after 3 days'
  task cancel_after_3_days: :environment do
    pending_bookings = Booking.where(status: 'pending')
    cancelled_bookings = []
    pending_bookings.each do |booking|
      if ((Time.current - booking.created_at)/1.hour).round > 72
        booking.update_column(:status, 'canceled')
        booking.update_column(:host_message, 'cancelled by system')
        cancelled_bookings.push(booking)
      end
    end
    puts "#{cancelled_bookings.length} pending booking(s) succesfully cancelled!"
  end

end
