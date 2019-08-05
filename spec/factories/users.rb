FactoryBot.define do
  factory :user do
    email { "kattbnb@fgreat.com" }
    password { "justanothersecurepassword" }
    password_confirmation { "justanothersecurepassword" }
    nickname { "george" }
    location { "Gothenburg" }
  end
end
