class Users::Serializer < ActiveModel::Serializer
  attributes :id, :location, :nickname
end
