class Customer < User
  has_many :orders
  has_many :ratings
  has_one :credit_card
  validates :first_name, :last_name, presence: true

  def current_order_in_progress
    Order.in_progress.take
  end

  def new_order
    Order.create(customer_id: self.id, completed_date: Date.today + 3.days)
  end
end
