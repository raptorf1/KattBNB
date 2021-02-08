FactoryBot.define do
  factory :user do
    email { 'kattbnb@fgreat.com' }
    password { 'justanothersecurepassword' }
    password_confirmation { 'justanothersecurepassword' }
    nickname { 'george' }
    location { 'Gothenburg' }
    message_notification { true }
    confirmed_at { '2019-08-10 09:56:34.588757' }
  end
end
