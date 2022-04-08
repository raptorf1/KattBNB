class Messages::Serializer < ActiveModel::Serializer
  attributes :id, :body, :created_at
  attribute :image
  belongs_to :user, serializer: Users::MessagesSerializer

  def image
    object.image.attached? ? AttachmentService.get_blob_url(object, false) : nil
  end
end
