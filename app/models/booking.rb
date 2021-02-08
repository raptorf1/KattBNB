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
end
