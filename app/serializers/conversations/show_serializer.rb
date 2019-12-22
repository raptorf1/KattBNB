class Conversations::ShowSerializer < ActiveModel::Serializer
  attributes :id
  has_many :message, serializer: Messages::Serializer
end
