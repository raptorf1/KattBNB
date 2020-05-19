class Review < ApplicationRecord
  belongs_to :user
  belongs_to :host_profile
  belongs_to :booking

  validates_presence_of :score, :body, :host_nickname
  validates :score, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 5 }
end


# body + host_reply 1000 chars