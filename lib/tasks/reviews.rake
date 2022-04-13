namespace :reviews do
  desc 'Notify user on pending review'
  task notify_pending_review: :environment do
    now_epoch_javascript = DateService.get_js_epoch
    all_accepted_bookings = Booking.where(status: 'accepted')
    all_accepted_bookings.each do |booking|
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
    unassociated_reviews = Review.where(user_id: nil, booking_id: nil, host_profile_id: nil)
    unassociated_reviews.each do |review|
      print "Unassociated review with id #{review.id} successfully deleted!"
      review.destroy
    end
  end
end
