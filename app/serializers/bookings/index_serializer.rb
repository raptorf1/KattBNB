class Bookings::IndexSerializer < ActiveModel::Serializer

  attributes :id, :number_of_cats, :dates, :status, :host_nickname, :message, :price_total, :created_at, :updated_at, :user_id

  belongs_to :user, serializer: Users::BookingsSerializer

end
