class Bookings::IndexSerializer < ActiveModel::Serializer

  attributes :id, :number_of_cats, :dates, :status, :host_nickname, :message, :price_total, :host_message, :host_avatar, :host_description, :host_full_address, :host_real_lat, :host_real_long, :created_at, :updated_at, :user_id

  belongs_to :user, serializer: Users::BookingsSerializer

end
