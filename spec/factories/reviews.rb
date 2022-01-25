FactoryBot.define do
  factory :review do
    score { 1 }
    body { 'MyText' }
    host_reply { 'MyText' }
    host_nickname { 'MyString' }
    association :user
    association :booking
    association :host_profile
  end
end
