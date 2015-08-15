FactoryGirl.define do
  factory :order_item do
    price "100.5"
    quantity "1"
    book
    order
  end

end
