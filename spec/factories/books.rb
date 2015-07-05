FactoryGirl.define do
  factory :book do
    title "My book"
    descirption "This book about ..."
    price 100.5
    books_in_stock 50
    author
    category
  end

end
