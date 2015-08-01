class OrderItem < ActiveRecord::Base
  belongs_to :book
  belongs_to :order
  validates :price, :quantity, :order_id, :book_id, presence: true
  validates :price, :quantity, numericality: true
end
