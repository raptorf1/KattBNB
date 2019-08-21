FactoryBot.define do
  factory :host_profile do
    user { nil }
    description { "MyText" }
    full_address { "MyString" }
    price_per_day_1_cat { "9.99" }
    supplement_price_per_cat_per_day { "9.99" }
    max_cats_accepted { 1 }
    availability { "MyText" }
    lat { "9.99" }
    long { "9.99" }
  end
end
