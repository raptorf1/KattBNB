class BookingsMailer < ApplicationMailer

  def notify_host_create_booking(host, booking, user)
    @booking = booking
    @host = host
    @user = user

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

  def notify_user_accepted_booking(host, booking, user)
    @booking = booking
    @host = host
    @user = user

    @start_date = Time.at(booking.dates[0] / 1000)
    @end_date = Time.at(booking.dates[booking.dates.length - 1] / 1000)

    mail(to: @user.email, subject: 'Your booking request got approved!')
  end

  def notify_user_declined_booking(host, booking, user)
    @booking = booking
    @host = host
    @user = user

    @start_date = Time.at(booking.dates[0] / 1000)
    @end_date = Time.at(booking.dates[booking.dates.length - 1] / 1000)

    mail(to: @user.email, subject: 'Your booking request got declined!')
  end

  def notify_user_cancelled_booking(host, booking, user)
    @booking = booking
    @host = host
    @user = user

    @start_date = Time.at(booking.dates[0] / 1000)
    @end_date = Time.at(booking.dates[booking.dates.length - 1] / 1000)

    mail(to: @user.email, subject: 'Your booking request got cancelled!')
  end

  def notify_host_cancelled_booking(host, booking, user)
    @booking = booking
    @host = host
    @user = user

    @start_date = Time.at(booking.dates[0] / 1000)
    @end_date = Time.at(booking.dates[booking.dates.length - 1] / 1000)

    mail(to: @host.email, subject: 'Cancelled booking request!')
  end

  def notify_host_on_user_account_deletion(host, booking, user)
    @booking = booking
    @host = host
    @user = user

    @start_date = Time.at(booking.dates[0] / 1000)
    @end_date = Time.at(booking.dates[booking.dates.length - 1] / 1000)

    string_with_2_decimals = sprintf('%.2f', booking.price_total.to_s)
    if string_with_2_decimals[string_with_2_decimals.length - 1] == '0' && string_with_2_decimals[string_with_2_decimals.length - 2] == '0'
      @total = string_with_2_decimals.to_i
    else
      @total = sprintf('%.2f', string_with_2_decimals)
    end

    mail(to: @host.email, subject: 'Important information about your upcoming booking!')
  end

end
