class Author < ActiveRecord::Base
  has_many :books
  validates :first_name, :last_name, presence: true

  def full_name
    first_name + " " + last_name unless first_name.nil?
  end
end
