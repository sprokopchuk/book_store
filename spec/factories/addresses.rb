FactoryGirl.define do
  factory :address do
    first_name {Faker::Name.name.split(" ")[0]}
    last_name {Faker::Name.name.split(" ")[1]}
    address {Faker::Address.street_address}
    zipcode {Faker::Address.zip_code}
    city {Faker::Address.city}
    phone {Faker::PhoneNumber.cell_phone}
    country
  end
end
