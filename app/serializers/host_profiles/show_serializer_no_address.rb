class HostProfiles::ShowSerializerNoAddress < ActiveModel::Serializer

  attributes :id, :description, :price_per_day_1_cat, :supplement_price_per_cat_per_day, :max_cats_accepted, :availability

  belongs_to :user, serializer: Users::Serializer

end
