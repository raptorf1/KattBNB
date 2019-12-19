FactoryBot.define do
  factory :conversation do
    association :user1, factory: :user
    association :user2, factory: :user, email: 'zane@mail.com', nickname: 'zanenkn'
  end
end
