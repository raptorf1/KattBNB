FactoryBot.define do
  factory :booking do
    number_of_cats { 1 }
    message { "MyText" }
    dates { "" }
    status { 1 }
    host_nickname { "MyString" }
    user { nil }
  end
end
