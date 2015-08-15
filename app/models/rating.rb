class Rating < ActiveRecord::Base

  scope :approved, -> { where(state: "approved") }
  scope :not_approved, -> {where(sate: "not approved")}
  scope :rejected, ->{where state: "rejected"}
  STATES = %w{approved not\ approved rejected}
  belongs_to :user
  belongs_to :book
  validates :review, :rate, presence: true
  validates :rate, inclusion: { in: 1..10 }

end
