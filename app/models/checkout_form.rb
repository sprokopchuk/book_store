class CheckoutForm
  include ActiveModel::Model
  include Virtus.model

  attr_reader :billing_address, :shipping_address, :credit_card, :delivery, :current_order

  attribute :current_order, Order
  attribute :billing_address, Address, default: :default_billing_address
  attribute :shipping_address, Address, default: :default_shipping_address
  attribute :credit_card, CreditCard, default: :default_credit_card
  attribute :delivery, Delivery, default: :default_delivery
  attribute :use_billing_as_shipping_address, Hash

  delegate :ready_to_checkout?, :next_step_checkout!, :confirm?,
          :address?, :delivery?, :payment?, to: :current_order
  delegate :current_state, :set_current_state_with_persistence, to: "@current_order.aasm"

  validates :billing_address, :shipping_address, presence: true, unless: ->{address?}
  validates :delivery, presence: true, unless: -> {address? || delivery?}
  validates :credit_card, presence: true, unless: ->{address? || delivery? || payment?}


  def save_or_update options = {}
    case current_state
      when :address
        create_or_update_addresses options[:billing_address], options[:shipping_address], options[:use_billing_as_shipping_address]
      when :payment
        create_or_update_credit_card options[:credit_card]
      when :delivery
        update_delivery_order options[:delivery]
    end
  end

  def to_previous_step?
    !valid?
  end
  def previous_step
    paths = { address: [:billing_address, :shipping_address],
              delivery: [:delivery],
              payment: [:credit_card]}
    paths.each do |action, obj|
      obj.each do |v|
        return "#{action}" if !valid? && current_order.send(:"#{v}").nil?
      end
    end
  end

private

  def default_billing_address
    current_order.billing_address
  end
  def default_shipping_address
    current_order.shipping_address
  end

  def default_credit_card
    current_order.credit_card
  end

  def create_or_update_addresses(billing_address_attrs = {},
                                  shipping_address_attrs = {},
                                  use_billing_as_shipping_address = "no")
    shipping_address_attrs = billing_address_attrs if use_billing_as_shipping_address == "yes"
    objs = {billing_address: billing_address_attrs,
            shipping_address: shipping_address_attrs}
    save_or_update_obj objs
  end

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
      else
        obj = current_order.send(:"#{k}")
        obj.assign_attributes(v)
      end
      promote_errors(obj.errors, k) and return false unless obj.valid?
      instance_variable_set("@#{k}", obj)
      result &&= instance_eval("@#{k}.save")
    end
    result
  end

  def promote_errors(child_errors, obj)
    child_errors.each do |attribute, message|
      errors["#{obj}.#{attribute}"] = message
    end
  end

end
