class Users::BookingsSerializer < ActiveModel::Serializer
  attributes :nickname, :location
  attribute :profile_avatar

  def profile_avatar
    object.profile_avatar.attached? ? AttachmentService.get_blob_url(object) : nil
  end
end
