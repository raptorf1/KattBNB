class Messages::Serializer < ActiveModel::Serializer

  include Rails.application.routes.url_helpers

  attributes :id, :body, :created_at
  attribute :image
  belongs_to :user, serializer: Users::MessagesSerializer


  def image
    object.image.attached? ? (Rails.env.test? ? rails_blob_url(object.image) : object&.image&.service_url(expires_in: 1.hour, disposition: 'inline')) : nil
  end

end
