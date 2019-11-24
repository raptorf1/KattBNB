class NewBookingRequestMailer < ApplicationMailer

  def notify_host(host)
    @host = host
    mail(to: @host.email, subject: 'New Booking Request Notification')
  end
  
end
