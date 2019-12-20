FactoryBot.define do
  factory :message do
    body { "MyString" }
    user { nil }
    conversation { nil }
  end
end
