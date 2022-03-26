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
    reviews = 0
    if ENV['OFFICIAL'] == 'yes'
      reviews = Review.get_host_profile_reviews_length(object.id).to_i
    else
      reviews = Review.where(host_profile_id: object.id).length.to_i
    end    
    return reviews unless reviews == 0
  end
end
