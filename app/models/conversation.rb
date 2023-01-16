class Conversation < ApplicationRecord
  belongs_to :user1, class_name: "User"
  belongs_to :user2, class_name: "User"

  has_many :message, dependent: :destroy

  validates_presence_of :user1_id, :user2_id

  def self.get_and_sort_conversations(logged_in_user_id)
    conversations = Conversation.where(user1_id: logged_in_user_id).or(Conversation.where(user2_id: logged_in_user_id))

    return(
      conversations
        .sort_by do |conversation|
          [conversation.message.last&.created_at ? 1 : 0, conversation.message.last&.created_at]
        end
        .reverse
    )
  end
end
