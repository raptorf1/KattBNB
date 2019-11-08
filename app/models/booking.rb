class Booking < ApplicationRecord
  belongs_to :user

  enum status: [:accepted, :pending, :declined]

  validates_presence_of :number_of_cats, :message, :dates, :host_nickname, :status, :user_id
end
