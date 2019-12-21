class Messages::Serializer < ActiveModel::Serializer
  attributes :body
  belongs_to :user, serializer: Users::Serializer
end