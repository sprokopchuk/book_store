class Orders::CheckoutController < ApplicationController

  before_action :authenticate_user!
  before_action :set_current_order, except: :complete
  before_action :set_addresses, only: [:fill_in_address, :confirm, :complete]
  before_action :set_default_delivery, only: :fill_in_delivery
  before_action :deliveries, only: :fill_in_delivery
  before_action :set_credit_card, only: :fill_in_payment

  def fill_in_address
    @billing_address ||= current_or_guest_user.build_billing_address
    @shipping_address ||= current_or_guest_user.build_shipping_address
    @current_order.aasm.set_current_state_with_persistence :fill_in_address
  end

  def fill_in_delivery
    redirect_to_checkout @billing_address, @shipping_address
    @current_order.aasm.set_current_state_with_persistence :fill_in_delivery
  end

  def update
    if current_or_guest_user.update_without_password(user_params) && @current_order.next_step_checkout!
      redirect_to :action => "#{@current_order.aasm.current_state.to_s}", :controller => "orders/checkout"
    end
  end

  def fill_in_payment
    redirect_to_checkout @billing_address, @shipping_address, @current_order.delivery_id
    @credit_card ||= current_or_guest_user.build_credit_card
    @current_order.aasm.set_current_state_with_persistence :fill_in_payment
  end

  def confirm
    redirect_to_checkout @billing_address, @shipping_address, @current_order.delivery_id, @current_order.credit_card
    @current_order.aasm.set_current_state_with_persistence :confirm
  end
  def complete
    @order = Order.find(params[:id])
    authorize! :complete, @order
  end

  private

  # redirect_to current_order, :billing_address, :shipping_address, :credit_card
  def redirect_to_checkout current_order, *objs
    objs_for_check = {}
    current_user = current_order.user
    objs.each { |obj| objs_for_check[obj] = current_user.send(obj)}
=begin
    objs.each do |obj|
      if obj.nil?
        redirect_to fill_in_address_checkout_path and return if objs[0].nil? || objs[0].nil?
        redirect_to fill_in_delivery_path and return if objs[0].nil?
        redirect_to fill_in_payment_path and return
        redirect_to confirm_path and return if state != :confirm
      end
    end
=end
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
