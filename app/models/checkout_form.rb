class CheckoutForm
  include ActiveModel::Model
  include Virtus.model

  def initialize current_order
    @current_order = current_order
  end

  attr_reader :billing_address, :shipping_address, :credit_card, :delivery, :current_order

  attribute :billing_address, Address
  attribute :shipping_address, Address
  attribute :credit_card, CreditCard
  attribute :delivery, Delivery
  attribute :current_order, Order

  def save
    case current_order.aasm.current_state
      when :fill_in_address
        if billing_address.valid? || shipping_address.valid?
          create_or_update_addresses
          true
        else
          false
        end
      when :fill_in_payment
        if credit_card.valid?
          create_or_update_credit_card
          true
        else
          false
        end
      when :fill_in_delivery
        if delivery.valid?
          update_delivery
          true
        else
          false
        end
    end
  end

  def save
    if valid?
      persist!
      true
    else
      false
    end
  end

private

  def create_or_update_addresses billing_address_attributes = {}, shipping_address_attributes = {}, use_shipping_as_billing_address = false, *params
    current_user = current_order.user
    shipping_address_attributes = billing_address_attributes if use_shipping_as_billing_address
    if current_user.billing_address.nil? || current_user.shipping_address.nil?
      @billing_address = current_user.create_billing_address(billing_address_attributes)
      @shipping_address = current_user.create_shipping_address(shipping_address_attributes)
    else
      @billing_address = current_user.billing_address.update(billing_address_attributes)
      @shipping_address = current_user.shipping_address.update(shipping_address_attributes)
    end
  end

  def create_or_update_credit_card credit_card_attributes = {}, *params
    current_user = current_order.user
    if current_order.user.credit_card.nil?
      @credit_card = current_user.create_credit_card(credit_card_attributes)
      current_order.update(credit_card_id: current_user.credit_card.id)
    else
      @credit_card = current_user.credit_card.update(credit_card_attributes)
      current_order.update(credit_card_id: current_user.credit_card.id)
    end
  end

  def update_delivery delivery_id = nil, *params
    current_order.update(delivery_id: delivery_id)
  end

end
