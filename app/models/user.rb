class User < ActiveRecord::Base

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:facebook]

  has_many :orders
  has_many :ratings
  has_one :credit_card
  has_one :billing_address, class_name: "Address", foreign_key: "billing_address_id"
  has_one :shipping_address, class_name: "Address", foreign_key: "shipping_address_id"
  accepts_nested_attributes_for :billing_address, :reject_if => :all_blank
  accepts_nested_attributes_for :shipping_address, :reject_if => :all_blank

  def current_order_in_progress
    current_order = self.orders.in_progress.take
    current_order.nil? ? self.orders.create : current_order
  end

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.email = auth.info.email
      user.password = Devise.friendly_token[0,20]
    end
  end
end
