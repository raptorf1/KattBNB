class BookingsMailer < ApplicationMailer

  def notify_host(host, booking)
    @booking = booking
    @host = host
    mail(to: @host.email, subject: 'You have a new booking request')
  end

end
