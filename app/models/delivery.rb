class Delivery < ActiveRecord::Base
  validate :name, :price, presence: true
  has_many :orders
end
