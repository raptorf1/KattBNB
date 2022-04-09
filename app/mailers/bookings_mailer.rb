class BookingsMailer < ApplicationMailer
  def notify_host_create_booking(host, booking, user)
    @booking = booking
    @host = host
    @user = user

    @start_date = DateService.get_date(booking.dates.first)
    @end_date = DateService.get_date(booking.dates.last)

    @total = PriceService.two_decimals_converter(booking.price_total)

    I18n.with_locale(@host.lang_pref) do
      mail(to: @host.email, subject: I18n.t('mailers.bookings.notify_host_create_booking'))
    end
  end

  def notify_user_accepted_booking(host, booking, user)
    @booking = booking
    @host = host
    @user = user

    @start_date = DateService.get_date(booking.dates.first)
    @end_date = DateService.get_date(booking.dates.last)

    final_charge = PriceService.calculate_kattbnb_charge(@booking.price_total)

    total = PriceService.two_decimals_converter(final_charge)

    I18n.with_locale(@user.lang_pref) do
      @summary_drop =
        I18n.t('mailers.bookings.notify_user_accepted_booking_sum_drop', total: total, host: @booking.host_nickname)
      @summary_collect =
        I18n.t('mailers.bookings.notify_user_accepted_booking_sum_collect', total: total, host: @booking.host_nickname)
    end
    event_drop = create_calendar_event(@start_date, @booking.host_full_address, @summary_drop)
    event_collect = create_calendar_event(@end_date, @booking.host_full_address, @summary_collect)
    attachments['AddToMyCalendarDropOff.ics'] = { mime_type: 'text/calendar', content: event_drop.to_ical }
    attachments['AddToMyCalendarPickUp.ics'] = { mime_type: 'text/calendar', content: event_collect.to_ical }

    I18n.with_locale(@user.lang_pref) do
      mail(to: @user.email, subject: I18n.t('mailers.bookings.notify_user_accepted_booking'))
    end
  end

  def notify_user_declined_booking(host, booking, user)
    @booking = booking
    @host = host
    @user = user

    @start_date = DateService.get_date(booking.dates.first)
    @end_date = DateService.get_date(booking.dates.last)

    I18n.with_locale(@user.lang_pref) do
      mail(to: @user.email, subject: I18n.t('mailers.bookings.notify_user_declined_booking'))
    end
  end

  def notify_user_cancelled_booking(host, booking, user)
    @booking = booking
    @host = host
    @user = user

    @start_date = DateService.get_date(booking.dates.first)
    @end_date = DateService.get_date(booking.dates.last)

    I18n.with_locale(@user.lang_pref) do
      mail(to: @user.email, subject: I18n.t('mailers.bookings.notify_user_cancelled_booking'))
    end
  end

  def notify_host_cancelled_booking(host, booking, user)
    @booking = booking
    @host = host
    @user = user

    @start_date = DateService.get_date(booking.dates.first)
    @end_date = DateService.get_date(booking.dates.last)

    I18n.with_locale(@host.lang_pref) do
      mail(to: @host.email, subject: I18n.t('mailers.bookings.notify_host_cancelled_booking'))
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
