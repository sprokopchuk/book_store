FactoryGirl.define do
  factory :address do
    address {Faker::Address.street_address}
    zipcode {Faker::Address.zip_code}
    city {Faker::Address.city}
    phone {Faker::PhoneNumber.cell_phone}
    country

    factory :billing_address do
      billing_address true
    end

    factory :shipping_address do
      shipping_address true
    end
  end
end
