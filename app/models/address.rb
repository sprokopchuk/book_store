class Address < ActiveRecord::Base
  belongs_to :country
  belongs_to :customer
  validates :address, :zipcode, :city, :phone, :country_id, presence: true
end
