class Conversations::IndexSerializer < ActiveModel::Serializer
  
  
  attributes :id, :last_msg
  belongs_to :user1, serializer: Users::Serializer
  belongs_to :user2, serializer: Users::Serializer
  
  def last_msg
    object.message.last
  end

end