class Reviews::Serializer < ActiveModel::Serializer
  ActiveModelSerializers.config.default_includes = '*.*'

  attributes :id, :score, :body, :host_reply, :host_nickname, :host_avatar, :created_at, :updated_at

  belongs_to :user, serializer: Users::Serializer

  def host_avatar
    host = User.find_by(nickname: object.host_nickname)
    return host.profile_avatar.attached? ? AttachmentService.get_blob_url(host) : nil unless host == nil
  end
end
