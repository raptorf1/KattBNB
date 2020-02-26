class Messages::Serializer < ActiveModel::Serializer

  include Rails.application.routes.url_helpers

  attributes :id, :body, :created_at
  attribute :image
  belongs_to :user, serializer: Users::MessagesSerializer


  def image
    if object.image.attached?
      if Rails.env.test?
        rails_blob_url(object.image)
      else
        object&.image&.service_url(expires_in: 1.hour, disposition: 'inline')
      end
    end
  end

end
