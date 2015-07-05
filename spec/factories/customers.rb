FactoryGirl.define do
  factory :customer do
    email {Faker::Internet.email}
    password "password"
    first_name {Faker::Name.name.split(" ")[0]}
    last_name {Faker::Name.name.split(" ")[1]}
  end

end
