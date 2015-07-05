class Author < ActiveRecord::Base
  has_many :books
  validates :first_name, :last_name, presence: true
end
