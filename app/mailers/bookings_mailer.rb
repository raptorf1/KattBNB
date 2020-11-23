class BookingsMailer < ApplicationMailer

  def notify_host_create_booking(host, booking, user)
    @booking = booking
    @host = host
    @user = user

    @start_date = Time.at(booking.dates[0] / 1000)
    @end_date = Time.at(booking.dates[booking.dates.length - 1] / 1000)

    string_with_2_decimals = sprintf('%.2f', booking.price_total.to_s)
    (string_with_2_decimals[string_with_2_decimals.length - 1] == '0' && string_with_2_decimals[string_with_2_decimals.length - 2] == '0') ? @total = string_with_2_decimals.to_i : @total = sprintf('%.2f', string_with_2_decimals)

    I18n.with_locale(@host.lang_pref) do
      mail(to: @host.email, subject: I18n.t('mailers.bookings.notify_host_create_booking'))
    end
  end

  def notify_user_accepted_booking(host, booking, user)
    @booking = booking
    @host = host
    @user = user

    @start_date = Time.at(booking.dates[0] / 1000)
    @end_date = Time.at(booking.dates[booking.dates.length - 1] / 1000)

    final_charge = @booking.price_total + (@booking.price_total * 0.17) + ((@booking.price_total * 0.17) * 0.25)
    string_with_2_decimals = sprintf('%.2f', final_charge.to_s)
    (string_with_2_decimals[string_with_2_decimals.length - 1] == '0' && string_with_2_decimals[string_with_2_decimals.length - 2] == '0') ? total = string_with_2_decimals.to_i : total = sprintf('%.2f', string_with_2_decimals)

    I18n.with_locale(@user.lang_pref) do
      @summary_drop = I18n.t('mailers.bookings.notify_user_accepted_booking_sum_drop', total: total, host: @booking.host_nickname)
      @summary_collect = I18n.t('mailers.bookings.notify_user_accepted_booking_sum_collect', total: total, host: @booking.host_nickname)
    end
    event_drop = create_calendar_event(@start_date, @booking.host_full_address, @summary_drop)
    event_collect = create_calendar_event(@end_date, @booking.host_full_address, @summary_collect)
    attachments['AddToMyCalendarDropOff.ics'] = { :mime_type => 'text/calendar', :content => event_drop.to_ical }
    attachments['AddToMyCalendarPickUp.ics'] = { :mime_type => 'text/calendar', :content => event_collect.to_ical }

    I18n.with_locale(@user.lang_pref) do
      mail(to: @user.email, subject: I18n.t('mailers.bookings.notify_user_accepted_booking'))
    end
  end

  def notify_user_declined_booking(host, booking, user)
    @booking = booking
    @host = host
    @user = user

    @start_date = Time.at(booking.dates[0] / 1000)
    @end_date = Time.at(booking.dates[booking.dates.length - 1] / 1000)

    I18n.with_locale(@user.lang_pref) do
      mail(to: @user.email, subject: I18n.t('mailers.bookings.notify_user_declined_booking'))
    end
  end

  def notify_user_cancelled_booking(host, booking, user)
    @booking = booking
    @host = host
    @user = user

    @start_date = Time.at(booking.dates[0] / 1000)
    @end_date = Time.at(booking.dates[booking.dates.length - 1] / 1000)

    I18n.with_locale(@user.lang_pref) do
      mail(to: @user.email, subject: I18n.t('mailers.bookings.notify_user_cancelled_booking'))
    end
  end

  def notify_host_cancelled_booking(host, booking, user)
    @booking = booking
    @host = host
    @user = user

    @start_date = Time.at(booking.dates[0] / 1000)
    @end_date = Time.at(booking.dates[booking.dates.length - 1] / 1000)

    I18n.with_locale(@host.lang_pref) do
      mail(to: @host.email, subject: I18n.t('mailers.bookings.notify_host_cancelled_booking'))
    end
  end

  def notify_host_on_user_account_deletion(host, booking, user)
    @booking = booking
    @host = host
    @user = user

    @start_date = Time.at(booking.dates[0] / 1000)
    @end_date = Time.at(booking.dates[booking.dates.length - 1] / 1000)

    string_with_2_decimals = sprintf('%.2f', booking.price_total.to_s)
    (string_with_2_decimals[string_with_2_decimals.length - 1] == '0' && string_with_2_decimals[string_with_2_decimals.length - 2] == '0') ? @total = string_with_2_decimals.to_i : @total = sprintf('%.2f', string_with_2_decimals)

    I18n.with_locale(@host.lang_pref) do
      mail(to: @host.email, subject: I18n.t('mailers.bookings.notify_host_on_user_account_deletion'))
    end
  end



  private

  def create_calendar_event(date, host_address, summary)
    cal = Icalendar::Calendar.new
    cal.event do |e|
      e.dtstart = Icalendar::Values::Date.new(date)
      e.dtend = Icalendar::Values::Date.new(date)
      e.location = host_address
      e.summary = summary
      e.description = ''
      e.ip_class = 'PRIVATE'
    end
    cal
  end

end
