namespace :reviews do
  desc 'Notify user on pending review'
  task notify_pending_review: :environment do
    now = DateTime.new(Time.now.year, Time.now.month, Time.now.day, 0, 0, 0, 0)
    now_epoch_javascript = (now.to_f * 1000).to_i
    accepted_bookings = Booking.where(status: 'accepted')
    notify_1 = []
    notify_3 = []
    notify_10 = []
    accepted_bookings.each do |booking|
      next unless booking.dates.last < now_epoch_javascript && booking.review == nil
        host = User.where(nickname: booking.host_nickname)
        user = User.where(id: booking.user_id)
        case (now_epoch_javascript - booking.dates.last)/86400000
          when 10
            ReviewsMailer.delay(:queue => 'reviews_email_notifications').notify_user_pending_review_10_days(host[0], user[0], booking)
            notify_10.push(booking)
          when 3
            ReviewsMailer.delay(:queue => 'reviews_email_notifications').notify_user_pending_review_3_days(host[0], user[0], booking)
            notify_3.push(booking)
          when 1
            ReviewsMailer.delay(:queue => 'reviews_email_notifications').notify_user_pending_review_1_day(host[0], user[0], booking)
            notify_1.push(booking)
        end
    end
    puts "#{notify_1.length} user(s) notified to leave review after 1 day!"
    puts "#{notify_3.length} user(s) notified to leave review after 3 days!"
    puts "#{notify_10.length} user(s) notified to leave review after 10 days!"
  end
end
