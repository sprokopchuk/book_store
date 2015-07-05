FactoryGirl.define do
  factory :order do
    total_price 0
    completed_date {Faker::Date.backward(3)}
    customer
    credit_card

    factory :order_shipped do
      state {"shipped"}
    end

  end
end
