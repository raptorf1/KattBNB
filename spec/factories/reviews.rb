FactoryBot.define do
  factory :review do
    score { 1 }
    body { 'MyText' }
    host_reply { 'MyText' }
    host_nickname { 'MyString' }
    association :user, factory: :user, id: 2, email: 'batman@mail.com', nickname: 'Thomas'
    association :booking, factory: :booking, user_id: 2
    association :host_profile, factory: :host_profile, user_id: 2
  end
end
