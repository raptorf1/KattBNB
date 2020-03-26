class BookingsMailer < ApplicationMailer

  def notify_host_create_booking(host, booking, user)
    @booking = booking
    @host = host
    @user = user

    @start_date = Time.at(booking.dates[0] / 1000)
    @end_date = Time.at(booking.dates[booking.dates.length - 1] / 1000)

    string_with_2_decimals = sprintf('%.2f', booking.price_total.to_s)
    (string_with_2_decimals[string_with_2_decimals.length - 1] == '0' && string_with_2_decimals[string_with_2_decimals.length - 2] == '0') ? @total = string_with_2_decimals.to_i : @total = sprintf('%.2f', string_with_2_decimals)

    mail(to: @host.email, subject: I18n.t('mailers.bookings.notify_host_create_booking'))
  end

  def notify_user_accepted_booking(host, booking, user)
    @booking = booking
    @host = host
    @user = user

    @start_date = Time.at(booking.dates[0] / 1000)
    @end_date = Time.at(booking.dates[booking.dates.length - 1] / 1000)

    mail(to: @user.email, subject: I18n.t('mailers.bookings.notify_user_accepted_booking'))
  end

  def notify_user_declined_booking(host, booking, user)
    @booking = booking
    @host = host
    @user = user

    @start_date = Time.at(booking.dates[0] / 1000)
    @end_date = Time.at(booking.dates[booking.dates.length - 1] / 1000)

    mail(to: @user.email, subject: I18n.t('mailers.bookings.notify_user_declined_booking'))
  end

  def notify_user_cancelled_booking(host, booking, user)
    @booking = booking
    @host = host
    @user = user

    @start_date = Time.at(booking.dates[0] / 1000)
    @end_date = Time.at(booking.dates[booking.dates.length - 1] / 1000)

    mail(to: @user.email, subject: I18n.t('mailers.bookings.notify_user_cancelled_booking'))
  end

  def notify_host_cancelled_booking(host, booking, user)
    @booking = booking
    @host = host
    @user = user

    @start_date = Time.at(booking.dates[0] / 1000)
    @end_date = Time.at(booking.dates[booking.dates.length - 1] / 1000)

    mail(to: @host.email, subject: I18n.t('mailers.bookings.notify_host_cancelled_booking'))
  end

  def notify_host_on_user_account_deletion(host, booking, user)
    @booking = booking
    @host = host
    @user = user

    @start_date = Time.at(booking.dates[0] / 1000)
    @end_date = Time.at(booking.dates[booking.dates.length - 1] / 1000)

    string_with_2_decimals = sprintf('%.2f', booking.price_total.to_s)
    (string_with_2_decimals[string_with_2_decimals.length - 1] == '0' && string_with_2_decimals[string_with_2_decimals.length - 2] == '0') ? @total = string_with_2_decimals.to_i : @total = sprintf('%.2f', string_with_2_decimals)

    mail(to: @host.email, subject: I18n.t('mailers.bookings.notify_host_on_user_account_deletion'))
  end

end
