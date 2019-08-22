FactoryBot.define do
  factory :host_profile do
    association :user
    description { "I am a man of constant sorrow and I love cats... I think" }
    full_address { "Kalamon 16, 2044, Strovolos, Nicosia, Cyprus" }
    price_per_day_1_cat { "100.35" }
    supplement_price_per_cat_per_day { "50.85" }
    max_cats_accepted { 3 }
    availability { [1560, 1561, 1562, 1563] }
    lat { "35.1018" }
    long { "33.38" }
  end
end
