class Bookings::IndexSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attributes :id,
             :number_of_cats,
             :dates,
             :status,
             :host_id,
             :host_profile_id,
             :host_profile_score,
             :host_location,
             :host_nickname,
             :message,
             :price_total,
             :host_message,
             :host_avatar,
             :host_description,
             :host_full_address,
             :host_real_lat,
             :host_real_long,
             :created_at,
             :updated_at,
             :user_id,
             :review_id

  belongs_to :user, serializer: Users::BookingsSerializer

  def host_id
    host = User.where(nickname: object.host_nickname)
    return host[0].id unless host.length == 0
  end

  def host_profile_id
    host = User.where(nickname: object.host_nickname)
    unless host.length == 0
      host_profile = HostProfile.where(user_id: host[0].id)
      return host_profile[0].id unless host_profile.length == 0
    end
  end

  def host_profile_score
    host = User.where(nickname: object.host_nickname)
    unless host.length == 0
      host_profile = HostProfile.where(user_id: host[0].id)
      return host_profile[0].score unless host_profile.length == 0
    end
  end

  def host_location
    host = User.where(nickname: object.host_nickname)
    return host[0].location unless host.length == 0
  end

  def host_avatar
    host = User.where(nickname: object.host_nickname)
    unless host.length == 0
      return(
        if host[0].profile_avatar.attached?
          (
            if Rails.env.test?
              rails_blob_url(host[0].profile_avatar)
            else
              host[0]&.profile_avatar&.service_url(expires_in: 1.hour, disposition: 'inline')
            end
          )
        else
          nil
        end
      )
    end
  end

  def review_id
    return object.review.id unless object.review == nil
  end
end
