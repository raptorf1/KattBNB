FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@factory.com" }
    password { 'justanothersecurepassword' }
    password_confirmation { 'justanothersecurepassword' }
    sequence(:nickname) { |n| "nickname_#{n}" }
    location { 'Gothenburg' }
    message_notification { true }
    confirmed_at { '2019-08-10 09:56:34.588757' }
  end
end
