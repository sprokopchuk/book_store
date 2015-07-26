class Address < ActiveRecord::Base
  belongs_to :country
  validates :first_name, :last_name, :address, :zipcode, :city, :phone, :country_id, presence: true
end
