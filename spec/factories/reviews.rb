FactoryBot.define do
  factory :review do
    score { 1 }
    body { "MyText" }
    host_reply { "MyText" }
    sequence(:host_nickname) { |n| "host_nickname_#{n}" }
    association :user
    association :booking
    association :host_profile
  end
end
