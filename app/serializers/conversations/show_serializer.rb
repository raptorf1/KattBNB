class Conversations::ShowSerializer < ActiveModel::Serializer
  attributes :id, :hidden, :responder
  has_many :message, serializer: Messages::Serializer
  belongs_to :user1
  belongs_to :user2

  def responder
    return Users::BookingsSerializer.new(object.user1.id != scope.id ? object.user1 : object.user2)
  end
end
