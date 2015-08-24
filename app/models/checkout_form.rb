class CheckoutForm
  include ActiveModel::Model
  include Virtus.model

  attr_reader :billing_address, :shipping_address, :credit_card, :delivery, :current_order

  attribute :current_order, Order
  attribute :billing_address, Address, default: :default_billing_address
  attribute :shipping_address, Address, default: :default_shipping_address
  attribute :credit_card, CreditCard, default: :default_credit_card
  attribute :delivery, Delivery, default: :default_delivery

  def save_or_update options = {}
    case current_order.aasm.current_state
      when :fill_in_address
        create_or_update_addresses options[:billing_address], options[:shipping_address], options[:use_shipping_as_billing_address]
      when :fill_in_payment
        create_or_update_credit_card options[:credit_card]
      when :fill_in_delivery
        update_delivery delivery
    end
  end

private

  def default_billing_address
    current_order.user.billing_address unless current_order.user.billing_address.nil?
  end
  def default_shipping_address
    current_order.user.shipping_address unless current_order.user.shipping_address.nil?
  end

  def default_credit_card
    current_order.user.credit_card unless current_order.user.credit_card.nil?
  end

  def default_delivery
    current_order.delivery unless current_order.delivery.nil?
  end
  def create_or_update_addresses billing_address_attributes = {}, shipping_address_attributes = {}, use_shipping_as_billing_address = false
    current_user = current_order.user
    shipping_address_attributes = billing_address_attributes if use_shipping_as_billing_address
    if current_user.billing_address.nil? || current_user.shipping_address.nil?
      billing_address = current_user.build_billing_address(billing_address_attributes)
      shipping_address = current_user.build_shipping_address(shipping_address_attributes)
      promote_errors(billing_address.errors) and return false unless billing_address.valid?
      promote_errors(shipping_address.errors) and return false unless shipping_address.valid?
      @shipping_address = shipping_address
      @billing_address = billing_address
      @shipping_address.save && @billing_address.save
    else
      current_user.billing_address.update(billing_address_attributes) && current_user.shipping_address.update(shipping_address_attributes)
    end
  end

  def create_or_update_credit_card credit_card_attributes = {}
    current_user = current_order.user
    if current_order.user.credit_card.nil?
      credit_card = current_user.create_credit_card(credit_card_attributes)
      promote_errors(credit_card.errors) and return false unless credit_card.valid?
      @credit_card = credit_card.save
    else
      @credit_card = current_user.credit_card.update(credit_card_attributes)
    end
    current_order.update(credit_card_id: current_user.credit_card.id)
  end

  def update_delivery delivery = {}
    current_order.update(delivery_id: delivery[:id])
  end

  def promote_errors(child_errors)
    child_errors.each do |attribute, message|
      errors.add(attribute, message)
    end
  end
end
