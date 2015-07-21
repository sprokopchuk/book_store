class Rating < ActiveRecord::Base

  #scope :approved, -> { where(state: "approved") }
  #scope :not_approved, -> {where(sate: "not approved")}
  STATES = %w{approved not\ approved reject}
  belongs_to :customer
  belongs_to :book
  validates :review, :rate, presence: true
  validates :rate, inclusion: { in: 1..10 }


end
