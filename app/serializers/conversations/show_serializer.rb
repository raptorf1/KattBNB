class Conversations::ShowSerializer < ActiveModel::Serializer
  attributes :id, :user1_id, :user2_id
  has_many :message, serializer: Messages::Serializer
end
