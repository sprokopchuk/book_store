class Customer < User
  has_many :orders
  has_many :ratings
  has_one :credit_card
  validates :first_name, :last_name, presence: true
  has_one :billing_address, class_name: "Address", foreign_key: "customer_billing_address_id"
  has_one :shipping_address, class_name: "Address", foreign_key: "customer_shipping_address_id"
  accepts_nested_attributes_for :billing_address, :allow_destroy => true
  accepts_nested_attributes_for :shipping_address, :allow_destroy => true

  def current_order_in_progress
    Order.in_progress.take
  end

  def new_order
    Order.create(customer_id: self.id, completed_date: Date.today + 3.days)
  end
end
