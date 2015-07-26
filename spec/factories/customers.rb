FactoryGirl.define do
  factory :customer do
    email {Faker::Internet.email}
    password "password"
  end
end
