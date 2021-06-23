class Message < ApplicationRecord
  has_one_attached :image

  belongs_to :user
  belongs_to :conversation
  before_create :check_message_for_email

  validates :body, length: { maximum: 1000 }

  private

  def check_message_for_email
    regex = /\A([\w+\-]\.?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
    if self.body.match(regex)
      raise StandardError.new('U CANT SEND EMAILS FUCKER')
    end
  end
end
