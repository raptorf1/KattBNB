module BookingService
  def self.validate_booking_creation_for_dates(host_nickname, booking_dates)
    host_booked_dates = []
    host_bookings = Booking.where(host_nickname: host_nickname)
    host_bookings.each do |host_booking|
      if host_booking.accepted? && host_booking.dates.last > DateService.get_js_epoch
        host_booked_dates.push(host_booking.dates)
      end
    end
    booking_dates - host_booked_dates.flatten.sort == booking_dates
  end
end
