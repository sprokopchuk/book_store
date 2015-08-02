class Order < ActiveRecord::Base

  scope :in_progress, -> { where(state: "in progress") }
  STATES = %w{in\ progress in\ queue in\ delivery delivered canceled}

  belongs_to :user
  belongs_to :credit_card
  has_many :order_items
  belongs_to :billing_address, class_name: "Address", foreign_key: "billing_address_id"
  belongs_to :shipping_address, class_name: "Address", foreign_key: "shipping_address_id"
  validates :total_price, :state, presence: true
  validates :total_price, numericality: true
  validates :state, inclusion: {in: STATES}
  accepts_nested_attributes_for :order_items, allow_destroy: true, :reject_if => :all_blank

  def add order_item
    item = OrderItem.find_by(book_id: order_item.book_id, order_id: self.id)
    if item.nil?
      self.order_items << order_item
    else
      amount_ordered = item.quantity
      amount_ordered += order_item.quantity
      item.update_attributes(quantity: amount_ordered)
    end
  end

  def real_price
    self.order_items.find_each {|item| self.total_price += item.price * item.quantity }
    self.total_price
  end

  def merge other_order
    current_order_items = self.order_items
    other_order.order_items.each do |order_item|
      if current_order_items.include? order_item
        current_order_item = OrderItem.find_by(book_id: order_item.book_id, order_id: self.id)
        amount_ordered = current_order_item.quantity
        amount_ordered += order_item.quantity
        current_order_item.update_attributes(quantity: amount_ordered)
     else
        order_item.order_id = self.id
        order_item.save
      end
    end
  end

end
