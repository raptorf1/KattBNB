class Message < ApplicationRecord
  belongs_to :user
  belongs_to :conversation

  validates_presence_of :body
  validates :body, length: { maximum: 1000 }

  # after_create_commit do
  #   MessageBroadcastJob.perform_later(self)
  # end
end
