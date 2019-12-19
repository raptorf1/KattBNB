class Conversation < ApplicationRecord
  belongs_to :user1, :class_name => 'User'
  belongs_to :user2, :class_name => 'User'

  validates_presence_of :user1_id, :user2_id
end
