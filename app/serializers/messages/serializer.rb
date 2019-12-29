class Messages::Serializer < ActiveModel::Serializer
  attributes :body, :created_at
  belongs_to :user, serializer: Users::MessagesSerializer
end
