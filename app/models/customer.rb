class Customer < ActiveRecord::Base
  has_many :orders
  has_many :ratings
  has_one :credit_card
  validates :email, :password, :first_name, :last_name, presence: true
  validates :email, uniqueness: true

  def current_order_in_progress
    Order.in_progress.take
  end

  def new_order
    Order.create(customer_id: self.id, completed_date: Date.today + 3.days)
  end
end
