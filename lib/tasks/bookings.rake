namespace :bookings do
  desc 'Cancel all pending bookings after 3 days'
  task cancel_after_3_days: :environment do
    pending_bookings = Booking.where(status: 'pending')
    pending_bookings.each do |booking|
      if ((Time.current - booking.created_at)/1.hour).round > 72
        booking.update_column(:status, 'canceled')
      end
    end
  end

end
