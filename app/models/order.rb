class Order < ActiveRecord::Base

  scope :in_progress, -> { where(state: "in progress") }
  STATES = %w{in\ progress in\ queue in\ delivery delivered canceled}

  before_save :real_price
  belongs_to :customer
  belongs_to :credit_card
  has_many :order_items
  belongs_to :billing_address, class_name: "Address", foreign_key: "billing_address_id"
  belongs_to :shipping_address, class_name: "Address", foreign_key: "shipping_address_id"
  validates :total_price, :completed_date, :state, presence: true
  validates :total_price, numericality: true
  validates :state, inclusion: {in: STATES}

  def add book, amount = 1
    order_item = OrderItem.find_by(book_id: book.id)
    if order_item.nil?
      self.order_items << OrderItem.new(price: book.price, book_id: book.id, quantity: amount)
    else
      amount_ordered = order_item.quantity
      amount_ordered += amount
      order_item.update_attributes(quantity: amount_ordered)
    end
  end

  def real_price
    self.order_items.find_each {|item| self.total_price += item.price * item.quantity }
    self.total_price
  end

end
