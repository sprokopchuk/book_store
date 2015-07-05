FactoryGirl.define do
  sequence :title do |n|
    "category_#{n}"
  end
  factory :category do
    title {FactoryGirl.generate(:title)}
  end

end
