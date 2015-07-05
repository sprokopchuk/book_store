class Rating < ActiveRecord::Base
  belongs_to :customer
  belongs_to :book
  validates :review, :rate, presence: true
  validates :rate, inclusion: { in: 1..10 }
end
