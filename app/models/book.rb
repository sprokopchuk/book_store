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

  def self.search query
    query.downcase!
    joins(:author).where('lower(trim(authors.first_name) || \' \' || trim(authors.last_name)) LIKE :search OR lower(books.title) LIKE :search OR lower(authors.first_name) LIKE :search OR lower(authors.last_name) LIKE :search', search: "%#{query}%")
  end
end
