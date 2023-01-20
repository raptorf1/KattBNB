module BookingService
  def self.validate_dates(host_nickname, booking_dates)
    host_bookings = Booking.where(host_nickname: host_nickname, status: "accepted")

    return true if host_bookings.empty?

    host_booked_dates = []
    host_bookings.each do |host_booking|
      host_booking.dates.last >= DateService.get_js_epoch && host_booked_dates.push(host_booking.dates)
    end
    booking_dates - host_booked_dates.flatten.sort == booking_dates
  end

  def self.cancel_same_date_pending_bookings_on_upate(host, booking_to_update_dates, booking_to_update_id)
    host_bookings = Booking.where(host_nickname: host.nickname, status: "pending")

    if !host_bookings.empty?
      host_bookings.each do |host_booking|
        if booking_to_update_dates - host_booking.dates != booking_to_update_dates
          host_booking.update(
            status: "canceled",
            host_message:
              "This booking got canceled by KattBNB. The host has accepted another booking in that date range."
          )
          StripeService.cancel_payment_intent(host_booking.payment_intent_id)
          BookingsMailer.delay(queue: "bookings_email_notifications").notify_user_declined_booking(
            host,
            host_booking,
            User.find(host_booking.user_id)
          )
          print "Host's #{host.nickname} pending booking with id #{host_booking.id} was canceled by the system cause of same dates with accepted booking with id #{booking_to_update_id}"
        end
      end
    end
  end
end
