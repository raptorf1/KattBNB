module BookingService
  def self.validate_booking_dates_on_creation(host_nickname, booking_dates)
    host_booked_dates = []
    host_bookings = Booking.where(host_nickname: host_nickname, status: "accepted")
    host_bookings.each do |host_booking|
      host_booking.dates.last > DateService.get_js_epoch && host_booked_dates.push(host_booking.dates)
    end
    booking_dates - host_booked_dates.flatten.sort == booking_dates
  end
end
