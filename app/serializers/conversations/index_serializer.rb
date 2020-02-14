class Conversations::IndexSerializer < ActiveModel::Serializer
  
  attributes :id, :msg_body, :msg_created, :hidden
  belongs_to :user1, serializer: Users::Serializer
  belongs_to :user2, serializer: Users::Serializer
  
  def msg_body
    unless object.message.last == nil
      return object.message.last.body
    end
  end

  def msg_created
    unless object.message.last == nil
      return object.message.last.created_at
    end
  end
end