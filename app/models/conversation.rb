class Conversation < ApplicationRecord
  belongs_to :user1, class_name: "User"
  belongs_to :user2, class_name: "User"

  has_many :message, dependent: :destroy

  validates_presence_of :user1_id, :user2_id

  def self.get_and_sort_conversations(logged_in_user_id)
    retrieved_conversations =
      Conversation
        .where(user1_id: logged_in_user_id)
        .or(Conversation.where(user2_id: logged_in_user_id))
        .select { |conversation| conversation.hidden != logged_in_user_id && !conversation.message.none? }

    return retrieved_conversations.sort_by { |conversation| conversation.message.last.created_at }.reverse
  end

  def self.check_conversation_exists_before_creating(params_user_1_id, params_user_2_id)
    return(
      Conversation.find_by(
        user1_id: [params_user_1_id, params_user_2_id],
        user2_id: [params_user_1_id, params_user_2_id]
      )&.id
    )
  end
end
