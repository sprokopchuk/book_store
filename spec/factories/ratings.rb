FactoryGirl.define do
  factory :rating do
    review "This is review"
    rate 5
    user
    book
  end

end
