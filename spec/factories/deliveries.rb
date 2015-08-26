FactoryGirl.define do
  factory :delivery do
    name {Faker::Lorem.sentence}
    price 15
  end

end
