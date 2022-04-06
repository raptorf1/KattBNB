class Reviews::Serializer < ActiveModel::Serializer
  ActiveModelSerializers.config.default_includes = '*.*'
  include Rails.application.routes.url_helpers

  attributes :id, :score, :body, :host_reply, :host_nickname, :host_avatar, :created_at, :updated_at

  belongs_to :user, serializer: Users::Serializer

  def host_avatar
    host = User.find_by(nickname: object.host_nickname)
    unless host == nil
      return(
        if host.profile_avatar.attached?
          (
            if Rails.env.test?
              rails_blob_url(host.profile_avatar)
            else
              host&.profile_avatar&.service_url(expires_in: 1.hour, disposition: 'inline')
            end
          )
        else
          nil
        end
      )
    end
  end
end
