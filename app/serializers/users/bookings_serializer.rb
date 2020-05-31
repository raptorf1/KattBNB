class Users::BookingsSerializer < ActiveModel::Serializer

  include Rails.application.routes.url_helpers

  attributes :nickname, :location
  attribute :profile_avatar

  def profile_avatar
    object.profile_avatar.attached? ? (Rails.env.test? ? rails_blob_url(object.profile_avatar) : object&.profile_avatar&.service_url(expires_in: 1.hour, disposition: 'inline')) : nil
  end

end
