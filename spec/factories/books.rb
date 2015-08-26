FactoryGirl.define do
  factory :book do
    title {Faker::Lorem.sentence}
    description {Faker::Lorem.sentence}
    price 100.5
    in_stock 50
    author
    category
  end

end
