class Users::BookingsSerializer < ActiveModel::Serializer
  attributes :nickname, :avatar, :location
end
