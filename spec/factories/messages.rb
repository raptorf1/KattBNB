FactoryBot.define do
  factory :message do
    body { "Hello! Don't kill the messenger!" }
    association :user
    association :conversation
  end
end
