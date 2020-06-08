class Reviews::Serializer < ActiveModel::Serializer

  ActiveModelSerializers.config.default_includes = '*.*'
  include Rails.application.routes.url_helpers

  attributes :id, :score, :body, :host_reply, :host_nickname, :host_avatar, :created_at, :updated_at

  belongs_to :user, serializer: Users::Serializer

  def host_avatar
    host = User.where(nickname: object.host_nickname)
    unless host.length == 0
      return host[0].profile_avatar.attached? ? (Rails.env.test? ? rails_blob_url(host[0].profile_avatar) : host[0]&.profile_avatar&.service_url(expires_in: 1.hour, disposition: 'inline')) : nil
    end
  end

end
