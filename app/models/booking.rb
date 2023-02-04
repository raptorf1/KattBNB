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
    if !user_id.nil?
      bookings_declined_canceled = Booking.where(status: %w[declined canceled], user_id: user_id)
      accepted_bookings = Booking.where(status: "accepted", user_id: user_id)
      history_bookings_accepted = accepted_bookings.select { |booking| booking.dates.last < DateService.get_js_epoch }
      all_history_bookings =
        (bookings_declined_canceled + history_bookings_accepted).sort_by { |booking| booking.dates.first }.reverse
      return all_history_bookings
    end

    bookings_declined_canceled = Booking.where(status: %w[declined canceled], host_nickname: host_nickname)
    accepted_bookings = Booking.where(status: "accepted", host_nickname: host_nickname)
    history_bookings_accepted = accepted_bookings.select { |booking| booking.dates.last < DateService.get_js_epoch }
    all_history_bookings =
      (bookings_declined_canceled + history_bookings_accepted).sort_by { |booking| booking.dates.first }.reverse
    return all_history_bookings
  end
end
