class OrderItem < ActiveRecord::Base
  belongs_to :book
  belongs_to :order
  validates :price, :quantity, presence: true
  validates :price, :quantity, numericality: true
end
