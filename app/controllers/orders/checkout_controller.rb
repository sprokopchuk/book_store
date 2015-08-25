class Orders::CheckoutController < ApplicationController

  before_action :authenticate_user!
  before_action :set_current_order, except: :complete
  before_action :set_addresses, only: [:address, :confirm, :complete]
  before_action :set_default_delivery, only: :delivery
  before_action :deliveries, only: :delivery
  before_action :set_credit_card, only: :payment

  def address
    @billing_address ||= current_user.build_billing_address
    @shipping_address ||= current_user.build_shipping_address
    @current_order.aasm.set_current_state_with_persistence :address
  end

  def delivery
    redirect_to_checkout(@current_order, :billing_address, :shipping_address); return if performed?
    @current_order.aasm.set_current_state_with_persistence :delivery
  end

  def update
    if current_or_guest_user.update_without_password(user_params) && @current_order.next_step_checkout!
      redirect_to :action => "#{@current_order.aasm.current_state.to_s}"
    end
  end

  def payment
    redirect_to_checkout(@current_order, :billing_address, :shipping_address, :delivery); return if performed?
    @credit_card ||= current_user.build_credit_card
    @current_order.aasm.set_current_state_with_persistence :payment
  end

  def confirm
    redirect_to_checkout(@current_order, :billing_address, :shipping_address, :delivery, :credit_card); return if performed?
    @current_order.aasm.set_current_state_with_persistence :confirm
  end
  def complete
    @order = Order.find(params[:id])
    authorize! :complete, @order
  end

  private

  def redirect_to_checkout current_order, *objs
    paths = { address: [:billing_address, :shipping_address],
              delivery: [:delivery],
              payment: [:credit_card]}
    current_user = current_order
    paths.each do |key, value|
      value.each do |v|
        return redirect_to action: "#{key}" if objs.include?(v) && current_order.send(:"#{v}").nil?
      end
    end
  end

  def set_current_order
    @current_order = current_user.current_order_in_progress
    redirect_to root_path, notice: t("current_order.no_items") unless @current_order.ready_to_checkout?
  end

  def set_addresses
    @billing_address = current_user.billing_address
    @shipping_address = current_user.shipping_address
  end

  def set_default_delivery
    @default_delivery = current_user.current_order_in_progress.delivery
    @default_delivery ||= Delivery.first
  end
  def deliveries
    @deliveries = Delivery.all
  end
  def set_credit_card
    @credit_card = current_user.credit_card
  end

  def user_params
    params.require(:user).permit(:billing_address_attributes => [:address, :city, :country_id, :zipcode, :phone, :id],
                                  :shipping_address_attributes => [:address, :city, :country_id, :zipcode, :phone, :id],
                                  :credit_card_attributes =>[:number, :cvv, :exp_month, :exp_year, :first_name, :last_name, :id],
                                  :orders_attributes => [:credit_card_id, :id])
  end

end
