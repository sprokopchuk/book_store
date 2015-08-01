class Book < ActiveRecord::Base
  has_many :ratings
  belongs_to :author
  belongs_to :category
  validates :title, :price, :in_stock, presence: true
  validates :price, :in_stock, numericality: true
  mount_uploader :image, ImageBookUploader

  def in_stock?
    self.in_stock > 0 ? true : false
  end
end
