class HostProfiles::IndexSerializer < ActiveModel::Serializer
  attributes :id,
             :description,
             :price_per_day_1_cat,
             :supplement_price_per_cat_per_day,
             :max_cats_accepted,
             :availability,
             :lat,
             :long,
             :score,
             :reviews_count

  belongs_to :user, serializer: Users::Serializer

  def reviews_count
    reviews = Review.where(host_profile_id: object.id)
    return reviews.length unless reviews.length == 0
  end
end
