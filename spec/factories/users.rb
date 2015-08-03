FactoryGirl.define do
  factory :user do
    first_name {Faker::Name.name.split(" ")[0]}
    last_name {Faker::Name.name.split(" ")[1]}
    email {Faker::Internet.email}
    password "password"
  end
end
