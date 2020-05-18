FactoryBot.define do
  factory :review do
    score { 1 }
    body { "MyText" }
    host_reply { "MyText" }
    host_nickname { "MyString" }
    user { nil }
    hostProfile { nil }
    booking { nil }
  end
end
