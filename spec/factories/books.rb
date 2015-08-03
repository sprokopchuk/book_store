FactoryGirl.define do
  factory :book do
    title "My book"
    description "This book about ..."
    price 100.5
    in_stock 50
    author
    category
  end

end
