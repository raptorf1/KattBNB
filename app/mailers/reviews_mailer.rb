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

end
