FactoryGirl.define do
  factory :order do
    total_price 0
    completed_date {Faker::Date.backward(3)}
    user
    credit_card

    factory :order_delivered do
      state {"delivered"}
    end

  end
end
