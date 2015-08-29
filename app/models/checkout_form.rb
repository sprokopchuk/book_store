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
      when :address
        create_or_update_addresses options[:billing_address], options[:shipping_address], options[:use_shipping_as_billing_address]
      when :payment
        create_or_update_credit_card options[:credit_card]
      when :delivery
        update_delivery_order options[:delivery]
    end
  end

private

  def default_billing_address
    current_order.billing_address unless current_order.billing_address.nil?
  end
  def default_shipping_address
    current_order.shipping_address unless current_order.shipping_address.nil?
  end

  def default_credit_card
    current_order.user.credit_card unless current_order.user.credit_card.nil?
  end

  def default_delivery
    current_order.delivery unless current_order.delivery.nil?
  end

  def create_or_update_addresses(billing_address_attrs = {},
                                  shipping_address_attrs = {},
                                  use_shipping_as_billing_address = false)
    shipping_address_attrs = billing_address_attrs if use_shipping_as_billing_address
    objs = {billing_address: billing_address_attrs,
            shipping_address: shipping_address_attrs}
    save_or_update_obj objs
  end
=begin

  def create_or_update(billing_address_attrs = {},
                        shipping_address_attrs = {},
                        use_shipping_as_billing_address = false)
    if current_user.billing_address.nil? || current_user.shipping_address.nil?
    billing_address = current_user.build_billing_address(billing_address_attributes)
    shipping_address = current_user.build_shipping_address(shipping_address_attributes)
      promote_errors(billing_address.errors) and return false unless billing_address.valid?
      promote_errors(shipping_address.errors) and return false unless shipping_address.valid?
      @shipping_address = shipping_address
      @billing_address = billing_address
      @shipping_address.save && @billing_address.save
    else
      return current_user.billing_address.update(billing_address_attributes) && current_user.shipping_address.update(shipping_address_attributes)
    end

  end
=end
  def create_or_update_credit_card credit_card_attrs = {}
    objs = {credit_card: credit_card_attrs}
    save_or_update_obj(objs) && current_order.update(credit_card_id: current_order.user.credit_card.id)
  end

  def update_delivery_order delivery_attrs = {}
    @delivery = Delivery.find_by(id: delivery_attrs[:id])
    current_order.update(delivery_id: delivery_attrs[:id]) unless @delivery.nil?
  end


  def save_or_update_obj objs = {}
    current_user = current_order.user
    result = ""
    objs.each do |k, v|
      if current_user.instance_eval("#{k}.nil?")
        obj = current_user.send(:"build_#{k}", v)
        promote_errors(obj.errors, k) and return false unless obj.valid?
        instance_variable_set("@#{k}", obj)
        result &&= instance_eval("@#{k}.save")
      else
        result &&= current_user.instance_eval("#{k}.update(#{v})")
      end
    end
    result
  end

  def promote_errors(child_errors, obj)
    child_errors.each do |attribute, message|
      errors["#{obj}.#{attribute}"] = message
    end
  end
end
