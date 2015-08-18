class Orders::CheckoutController < ApplicationController

  before_action :authenticate_user!
  before_action :set_current_order, except: :complete
  before_action :set_addresses, only: [:fill_in_address, :confirm]
  before_action :set_default_delivery, only: :fill_in_delivery
  before_action :deliveries, only: :fill_in_delivery
  before_action :set_credit_card, only: :fill_in_payment

  def fill_in_address
    @billing_address ||= current_or_guest_user.build_billing_address
    @shipping_address ||= current_or_guest_user.build_shipping_address
    @current_order.aasm.set_current_state_with_persistence :fill_in_address
  end

  def fill_in_delivery
    keys = keys_redirect @current_order, :fill_in_delivery, 1
    redirect_to :action => "#{keys[0]}", :controller => "orders/checkout" if keys.any?
    @current_order.aasm.set_current_state_with_persistence :fill_in_delivery
  end

  def update
    if current_or_guest_user.update_without_password(user_params) && @current_order.next_step_checkout!
      redirect_to :action => "#{@current_order.aasm.current_state.to_s}", :controller => "orders/checkout"
    else
      redirect_to :back
    end
  end

  def fill_in_payment
    keys = keys_redirect @current_order, :fill_in_payment, 2
    redirect_to :action => "#{keys[0]}", :controller => "orders/checkout" if keys.any?
    @credit_card ||= current_or_guest_user.build_credit_card
    @current_order.aasm.set_current_state_with_persistence :fill_in_payment
  end

  def confirm
    keys = keys_redirect @current_order, :confirm, 3
    redirect_to :action => "#{keys[0]}", :controller => "orders/checkout" if keys.any?
    @current_order.aasm.set_current_state_with_persistence :confirm
  end
  def complete
    @order = Order.find(params[:id])
    authorize! :complete, @order
  end

  private

  def keys_redirect order, state, num
    objs = {:fill_in_address => [order.user.billing_address, order.user.shipping_address],
            :fill_in_delivery => [order.delivery_id],
            :fill_in_payment => [order.credit_card]}
    keys_redirect = []
    objs.keys.take(num).each do |key|
      case objs[key].length
        when 2 then keys_redirect << key if objs[key][0].nil? || objs[key][1].nil?
        when 1 then keys_redirect << key if objs[key][0].nil?
      end
    end
    keys_redirect
  end

  def set_current_order
    @current_order = current_or_guest_user.current_order_in_progress
  end

  def set_addresses
    @billing_address = current_or_guest_user.billing_address
    @shipping_address = current_or_guest_user.shipping_address
  end

  def set_default_delivery
    @default_delivery = current_or_guest_user.current_order_in_progress.delivery
    @default_delivery ||= Delivery.first
  end
  def deliveries
    @deliveries = Delivery.all
  end
  def set_credit_card
    @credit_card = current_or_guest_user.credit_card
  end
  def user_params
    params.require(:user).permit(:billing_address_attributes => [:address, :city, :country_id, :zipcode, :phone, :id],
                                  :shipping_address_attributes => [:address, :city, :country_id, :zipcode, :phone, :id],
                                  :credit_card_attributes =>[:number, :cvv, :exp_month, :exp_year, :first_name, :last_name, :id],
                                  :orders_attributes => [:credit_card_id, :id])
  end

end
