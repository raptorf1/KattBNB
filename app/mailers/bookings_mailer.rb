class BookingsMailer < ApplicationMailer

  def notify_host(host, booking)
    @booking = booking
    @host = host

    @start_date = Time.at(booking.dates[0] / 1000)
    @end_date = Time.at(booking.dates[booking.dates.length - 1] / 1000)

    string_with_2_decimals = sprintf('%.2f', booking.price_total.to_s)
    if string_with_2_decimals[string_with_2_decimals.length - 1] == '0' && string_with_2_decimals[string_with_2_decimals.length - 2] == '0'
      @total = string_with_2_decimals.to_i
    else
      @total = sprintf('%.2f', string_with_2_decimals)
    end

    mail(to: @host.email, subject: 'You have a new booking request!')
  end

end
