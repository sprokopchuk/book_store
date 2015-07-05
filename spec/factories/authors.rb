FactoryGirl.define do
  factory :author do
    first_name {Faker::Name.name.split(" ")[0]}
    last_name {Faker::Name.name.split(" ")[1]}
    biography "This is my biography"
  end

end
