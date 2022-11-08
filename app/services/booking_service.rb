module BookingService
  def self.get_host_upcoming_booking_dates(host_nickname)
    host_booked_dates = []
    host_bookings = Booking.where(host_nickname: host_nickname)
    host_bookings.each do |host_booking|
      if host_booking.accepted? && host_booking.dates.last > DateService.get_js_epoch
        host_booked_dates.push(host_booking.dates)
      end
    end
    host_booked_dates.flatten.sort
  end
end
