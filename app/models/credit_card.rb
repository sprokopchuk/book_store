class CreditCard < ActiveRecord::Base
  belongs_to :customer
  has_many :orders
  validates :number, :cvv, :exp_month, :exp_year, :first_name, :last_name, presence: true
  validates :exp_month, inclusion: { in: 1..12 }
  validates :cvv, numericality: true
  validates :number, length: { is: 16 }
end
