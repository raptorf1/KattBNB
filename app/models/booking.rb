class Booking < ApplicationRecord
  belongs_to :user

  enum status: [:accepted, :pending, :declined]

end
