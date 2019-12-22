class HostProfiles::ShowSerializer < ActiveModel::Serializer

  attributes :id, :description, :full_address, :price_per_day_1_cat, :supplement_price_per_cat_per_day, :max_cats_accepted, :availability, :forbidden_dates
  
  belongs_to :user, serializer: Users::Serializer

end
