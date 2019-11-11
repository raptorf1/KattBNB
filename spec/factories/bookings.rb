FactoryBot.define do
  factory :booking do
    association :user
    number_of_cats { 1 }
    message { "Yo mannnnnn!" }
    dates { [1560, 1561, 1562, 1563] }
    status { 1 }
    price_per_day { 156.36 }
    price_total { 1550 }
    host_nickname { "Boa" }
  end
end
