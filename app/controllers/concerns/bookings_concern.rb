module BookingsConcern
  extend ActiveSupport::Concern

  included do
    helper_method :find_host_bookings
  end

  def find_host_bookings (nickname, id_number)
    now = DateTime.new(Time.now.year, Time.now.month, Time.now.day, 0, 0, 0, 0)
    now_epoch_javascript = (now.to_f * 1000).to_i
    host_booked_dates = []
    host_bookings = Booking.where(host_nickname: nickname)
    host_bookings.each do |host_booking|
      if id_number > 0
        if host_booking.id != id_number && (host_booking.status == 'accepted' && host_booking.dates.last > now_epoch_javascript)
          host_booked_dates.push(host_booking.dates)
        end
      else
        next unless host_booking.status == 'accepted' && host_booking.dates.last > now_epoch_javascript
          host_booked_dates.push(host_booking.dates)
      end
    end
    host_booked_dates.flatten.sort
  end
end
