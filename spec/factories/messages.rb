FactoryBot.define do
  factory :message do
    body { "Hello! Don't kill the messenger!" }
    association :user, factory: :user, email: 'joel@mail.com', nickname: 'gaJoel'
    association :conversation
  end
end
