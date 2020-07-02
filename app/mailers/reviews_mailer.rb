class ReviewsMailer < ApplicationMailer

  def notify_host_create_review(host, booking, user, review)
    @review = review
    @host = host
    @user = user

    @start_date = Time.at(booking.dates[0] / 1000)
    @end_date = Time.at(booking.dates[booking.dates.length - 1] / 1000)

    I18n.with_locale(@host.lang_pref) do
      mail(to: @host.email, subject: I18n.t('mailers.reviews.notify_host_create_review'))
    end
  end

  def notify_user_pending_review_1_day(host, user, booking)
    @host = host
    @user = user
    @booking = booking
    @profile = HostProfile.where(user_id: host.id)[0]

    I18n.with_locale(@user.lang_pref) do
      mail(to: @user.email, subject: I18n.t('mailers.reviews.notify_user_pending_review', host: @host.nickname))
    end
  end

  def notify_user_pending_review_3_days(host, user, booking)
    @host = host
    @user = user
    @booking = booking
    @profile = HostProfile.where(user_id: host.id)[0]

    I18n.with_locale(@user.lang_pref) do
      mail(to: @user.email, subject: I18n.t('mailers.reviews.notify_user_pending_review', host: @host.nickname))
    end
  end

  def notify_user_pending_review_10_days(host, user, booking)
    @host = host
    @user = user
    @booking = booking
    @profile = HostProfile.where(user_id: host.id)[0]

    I18n.with_locale(@user.lang_pref) do
      mail(to: @user.email, subject: I18n.t('mailers.reviews.notify_user_pending_review', host: @host.nickname))
    end
  end

end
