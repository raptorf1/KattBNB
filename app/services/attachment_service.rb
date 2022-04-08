module AttachmentService
  class << self
    include Rails.application.routes.url_helpers

    def get_blob_url(obj, avatar = true)
      if avatar
        if Rails.env.test?
          rails_blob_url(obj.profile_avatar)
        else
          obj&.profile_avatar&.service_url(expires_in: 1.hour, disposition: 'inline')
        end
      else
        Rails.env.test? ? rails_blob_url(obj.image) : obj&.image&.service_url(expires_in: 1.hour, disposition: 'inline')
      end
    end
  end
end
