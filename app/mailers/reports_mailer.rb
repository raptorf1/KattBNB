class ReportsMailer < ApplicationMailer
  def bookings_revenue_and_vat(booking)
    id = booking.id
    @host = booking.host_nickname
    @days = booking.dates.length
    @host_price = booking.price_total

    mail(to: "raptor_f1@hotmail.com", subject: "New paid booking with id #{id}")
  end
end
