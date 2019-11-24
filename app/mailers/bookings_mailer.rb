class BookingsMailer < ApplicationMailer

  def notify_host(host, booking)
    @booking = booking
    @host = host
    @start_date = Time.at(booking.dates[0] / 1000)
    @end_date = Time.at(booking.dates[booking.dates.length - 1] / 1000)
    mail(to: @host.email, subject: 'You have a new booking request!')
  end

end
