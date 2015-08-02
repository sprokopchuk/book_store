class Address < ActiveRecord::Base
  belongs_to :country
  validates :address, :zipcode, :city, :phone, :country_id, presence: true
end
