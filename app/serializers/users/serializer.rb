class Users::Serializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attributes :id, :location, :nickname
  attribute :profile_avatar

  def profile_avatar
    if object.profile_avatar.attached?
      (
        if Rails.env.test?
          rails_blob_url(object.profile_avatar)
        else
          object&.profile_avatar&.service_url(expires_in: 1.hour, disposition: 'inline')
        end
      )
    else
      nil
    end
  end
end
