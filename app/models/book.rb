class Book < ActiveRecord::Base
  has_many :ratings
  belongs_to :author
  belongs_to :category
  validates :title, :price, :books_in_stock, presence: true
  validates :price, :books_in_stock, numericality: true
  mount_uploader :image, ImageBookUploader
end
