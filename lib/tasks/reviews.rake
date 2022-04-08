namespace :reviews do
  desc 'Notify user on pending review'
  task notify_pending_review: :environment do
    now = DateTime.new(Time.now.year, Time.now.month, Time.now.day, 0, 0, 0, 0)
    now_epoch_javascript = (now.to_f * 1000).to_i
    Booking
      .where(status: 'accepted')
      .each do |booking|
        next unless booking.dates.last < now_epoch_javascript && booking.review == nil
        host = User.find_by(nickname: booking.host_nickname)
        user = User.find_by(id: booking.user_id)
        if host != nil && user != nil
          case (now_epoch_javascript - booking.dates.last) / 86_400_000
          when 10
            ReviewsMailer
              .delay(queue: 'reviews_email_notifications')
              .notify_user_pending_review_10_days(host, user, booking)
            print "User #{user.nickname} notified to leave review after 10 days for booking with id #{booking.id}!"
          when 3
            ReviewsMailer
              .delay(queue: 'reviews_email_notifications')
              .notify_user_pending_review_3_days(host, user, booking)
            print "User #{user.nickname} notified to leave review after 3 days for booking with id #{booking.id}!"
          when 1
            ReviewsMailer
              .delay(queue: 'reviews_email_notifications')
              .notify_user_pending_review_1_day(host, user, booking)
            print "User #{user.nickname} notified to leave review after 1 day for booking with id #{booking.id}!"
          end
        else
          print 'User or host is deleted. Sending notification mail aborted!'
        end
      end
  end

  desc 'Delete unassociated reviews'
  task delete_unassociated_reviews: :environment do
    Review
      .where(user_id: nil, booking_id: nil, host_profile_id: nil)
      .each do |review|
        print "Unassociated review with id #{review.id} successfully deleted!"
        review.destroy
      end
  end
end
