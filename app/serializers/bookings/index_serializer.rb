class Bookings::IndexSerializer < ActiveModel::Serializer

  include Rails.application.routes.url_helpers

  attributes :id, :number_of_cats, :dates, :status, :host_id, :host_location, :host_nickname, :message, :price_total, :host_message, :host_avatar, :host_description, :host_full_address, :host_real_lat, :host_real_long, :created_at, :updated_at, :user_id

  belongs_to :user, serializer: Users::BookingsSerializer
  has_one :review, serializer: Reviews::Serializer

  def host_id
    host = User.where(nickname: object.host_nickname)
    unless host.length == 0
      return host[0].id
    end
  end

  def host_location
    host = User.where(nickname: object.host_nickname)
    unless host.length == 0
      return host[0].location
    end
  end

  def host_avatar
    host = User.where(nickname: object.host_nickname)
    host[0].profile_avatar.attached? ? (Rails.env.test? ? rails_blob_url(host[0].profile_avatar) : host[0]&.profile_avatar&.service_url(expires_in: 1.hour, disposition: 'inline')) : nil
  end

end
