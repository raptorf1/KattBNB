class Message < ApplicationRecord
  has_one_attached :image

  belongs_to :user
  belongs_to :conversation
  before_create :check_message_for_email_or_phone_number

  validates :body, length: { maximum: 1000 }

  private

  def check_message_for_email_or_phone_number
    email_regexp = /\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i
    raise StandardError.new('no emails or phones') if email_regexp.match?(self.body)
  end
end
