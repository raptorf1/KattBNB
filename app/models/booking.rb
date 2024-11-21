class Booking < ApplicationRecord
  belongs_to :user

  has_one :review, dependent: :nullify

  enum status: %i[accepted pending declined canceled]

  validates_presence_of :number_of_cats,
                        :message,
                        :dates,
                        :host_nickname,
                        :status,
                        :price_per_day,
                        :price_total,
                        :user_id
  validates :message, length: { maximum: 400 }
  validates :host_message, length: { maximum: 200 }

  def self.cached_by_host_profile_id(host_profile_id)
    if Rails.cache.fetch("bookings_with_host_profile_id_#{host_profile_id}").nil?
      response = Booking.where(host_profile_id: host_profile_id)
      Rails.cache.fetch("bookings_with_host_profile_id_#{host_profile_id}") { response }
      response
    else
      Rails.cache.fetch("bookings_with_host_profile_id_#{host_profile_id}")
    end
  end

  def self.get_history_bookings_sorted(host_nickname, user_id)
    bookings_declined_canceled =
      (
        if user_id.nil?
          Booking.where(status: %w[declined canceled], host_nickname: host_nickname)
        else
          Booking.where(status: %w[declined canceled], user_id: user_id)
        end
      )
    accepted_bookings =
      (
        if user_id.nil?
          Booking.where(status: "accepted", host_nickname: host_nickname)
        else
          Booking.where(status: "accepted", user_id: user_id)
        end
      )
    history_bookings_accepted = accepted_bookings.select { |booking| booking.dates.last < DateService.get_js_epoch }
    all_history_bookings =
      (bookings_declined_canceled + history_bookings_accepted).sort_by { |booking| booking.dates.first }.reverse
    return all_history_bookings
  end

  def self.get_request_bookings_sorted(host_nickname, user_id)
    pending_bookings =
      (
        if user_id.nil?
          Booking.where(status: "pending", host_nickname: host_nickname)
        else
          Booking.where(status: "pending", user_id: user_id)
        end
      )
    return pending_bookings.sort_by { |booking| booking.created_at }.reverse
  end

  def self.get_upcoming_bookings_sorted(host_nickname, user_id)
    accepted_bookings =
      (
        if user_id.nil?
          Booking.where(status: "accepted", host_nickname: host_nickname)
        else
          Booking.where(status: "accepted", user_id: user_id)
        end
      )
    upcoming_bookings =
      accepted_bookings
        .select { |booking| booking.dates.last >= DateService.get_js_epoch }
        .sort_by { |booking| booking.dates.first }
    return upcoming_bookings
  end

  def self.get_booking_stats(host_nickname, user_id)
    pending_bookings =
      (
        if user_id.nil?
          Booking.where(status: "pending", host_nickname: host_nickname).size
        else
          Booking.where(status: "pending", user_id: user_id).size
        end
      )
    unpaid_bookings =
      user_id.nil? ? Booking.where(status: "accepted", host_nickname: host_nickname, paid: false).size : 0
    history_bookings_declined_canceled =
      (
        if user_id.nil?
          Booking.where(status: %w[declined canceled], host_nickname: host_nickname).size
        else
          Booking.where(status: %w[declined canceled], user_id: user_id).size
        end
      )
    accepted_bookings =
      (
        if user_id.nil?
          Booking.where(status: "accepted", host_nickname: host_nickname).select("dates")
        else
          Booking.where(status: "accepted", user_id: user_id).select("dates")
        end
      )

    upcoming_bookings = accepted_bookings.select { |booking| booking.dates.last >= DateService.get_js_epoch }.size
    history_bookings_accepted = accepted_bookings.size - upcoming_bookings

    if user_id.nil?
      return(
        {
          stats: {
            in_requests: pending_bookings,
            in_upcoming: upcoming_bookings,
            in_history: history_bookings_accepted + history_bookings_declined_canceled,
            in_unpaid: unpaid_bookings
          }
        }.to_json
      )
    end

    return(
      {
        stats: {
          out_requests: pending_bookings,
          out_upcoming: upcoming_bookings,
          out_history: history_bookings_accepted + history_bookings_declined_canceled
        }
      }.to_json
    )
  end
end
