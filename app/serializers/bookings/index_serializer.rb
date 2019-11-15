class Bookings::IndexSerializer < ActiveModel::Serializer

  attributes :id, :number_of_cats, :dates, :status, :host_nickname, :price_total, :created_at, :updated_at, :user_id

end
