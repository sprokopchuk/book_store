FactoryGirl.define do
  factory :rating do
    review "This is review"
    rate "5"
    user
    book

    factory :rating_approved do
      state "approved"
    end

    factory :rating_rejected do
      state "rejected"
    end
  end

end
