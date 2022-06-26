class Conversations::ShowSerializer < ActiveModel::Serializer
  attributes :id, :hidden, :responder
  has_many :message, serializer: Messages::Serializer
  belongs_to :user1
  belongs_to :user2

  def responder
    resp = object.user1.id != scope.id ? object.user1 : object.user2
    return resp.nil? ? nil : Users::BookingsSerializer.new(resp) 
  end
end
