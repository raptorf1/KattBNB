class Message < ApplicationRecord

  has_one_attached :image

  belongs_to :user
  belongs_to :conversation

  validates_presence_of :body
  validates :body, length: { maximum: 1000 }

end
