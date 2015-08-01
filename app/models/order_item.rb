class OrderItem < ActiveRecord::Base
  belongs_to :book
  belongs_to :order
  validates :price, :quantity, :order_id, :book_id, presence: true
  validates :price, :quantity, numericality: true

  def ==(other_order_item)
    self.book_id == other_order_item.book_id
  end
end
