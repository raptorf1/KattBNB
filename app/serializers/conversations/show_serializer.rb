class Conversations::ShowSerializer < ActiveModel::Serializer
  attributes :id, :hidden
  has_many :message, serializer: Messages::Serializer
end
