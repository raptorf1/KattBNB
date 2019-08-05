FactoryBot.define do
  factory :user do
    email { "kattbnb@fgreat.com" }
    password { "justanothersecurepassword" }
    password_confirmation { "justanothersecurepassword" }
  end
end
