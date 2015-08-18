class Order < ActiveRecord::Base

  include AASM
  scope :in_progress, -> {where state: ['in_progress', "fill_in_address", "fill_in_delivery", "fill_in_payment", "confirm"]}
  belongs_to :user
  belongs_to :credit_card
  has_many :order_items
  belongs_to :delivery
  validates :total_price, :state, presence: true
  validates :total_price, numericality: true
  accepts_nested_attributes_for :order_items, allow_destroy: true

  aasm :whiny_transitions => false, :column => 'state' do
    state :in_progress, :initial => true
    state :fill_in_address
    state :fill_in_delivery
    state :fill_in_payment
    state :confirm
    state :in_queue
    state :in_delivery
    state :delivered
    state :canceled

    event :next_step_checkout do
      transitions :from => :in_progress, :to => :fill_in_address
      transitions :from => :fill_in_address, :to => :fill_in_delivery
      transitions :from => :fill_in_delivery, :to => :fill_in_payment
      transitions :from => :fill_in_payment, :to => :confirm
      transitions :from => :confirm, :to => :in_queue
    end

    event :in_delivery do
      transitions :from => :in_queue, :to => :in_delivery
    end

    event :cancel do
      transitions :from => [:in_queue, :in_delivery], :to => :canceled
    end
    event :delivered do
      transitions :from => :in_delivery, :to => :delivered
    end

  end

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
    self.total_price = 0
    self.order_items.find_each do |item|
      self.total_price += item.price * item.quantity
    end
    self.total_price
  end

  def price_with_delivery
    self.delivery.nil? ? real_price : real_price + delivery.price
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
