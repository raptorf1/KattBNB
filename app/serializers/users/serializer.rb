class Users::Serializer < ActiveModel::Serializer
  attributes :id, :location, :nickname, :avatar
end
