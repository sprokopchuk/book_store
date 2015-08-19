class Rating < ActiveRecord::Base

  include AASM
  belongs_to :user
  belongs_to :book
  validates :review, :rate, presence: true
  validates :rate, inclusion: { in: 1..10 }
  aasm :whiny_transitions => false, :column => 'state' do
    state :not_approved, :initial => true
    state :approved
    state :rejected
    event :approve do
      transitions :from => :not_approved, :to => :approved
    end
    event :reject do
      transitions :from => :not_approved, :to => :rejected
    end
  end
end
