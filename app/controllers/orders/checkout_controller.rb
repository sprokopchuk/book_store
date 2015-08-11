class Orders::CheckoutController < ApplicationController

  before_action :set_current_order
  before_action :set_addresses, except: :update
  before_action :set_delivery, only: [:devlivery, :fill_in_payment, :confirm, :complete]
  before_action :set_credit_card, only: [:fill_in_payment, :confirm, :complete]

  def fill_in_address
    @billing_address ||= current_user.build_billing_address
    @shipping_address ||= current_user.build_shipping_address
    @current_order.aasm.set_current_state_with_persistence :fill_in_address
  end

  def fill_in_delivery
    redirect_to_checkout @billing_address, @shipping_address, :fill_in_delivery
    #@delivery ||= current_user.build_delivery
    @current_order.aasm.set_current_state_with_persistence :fill_in_delivery
  end

  def update
    if current_user.update_without_password(user_params) && @current_order.next_step_checkout!
      redirect_to :action => "#{@current_order.aasm.current_state.to_s}", :controller => "orders/checkout"
    else
      redirect_to :back
    end
  end

  def fill_in_payment
    redirect_to_checkout @billing_address, @shipping_address, @delivery, :fill_in_payment
    @credit_card ||= current_user.build_credit_card
    @current_order.aasm.set_current_state_with_persistence :fill_in_payment
  end

  def confirm
    redirect_to_checkout @billing_address, @shipping_address, @delivery, @credit_card, :confirm
    @current_order.aasm.set_current_state_with_persistence :confirm
  end

  def complete
    redirect_to_checkout @billing_address, @shipping_address, @delivery, @credit_card, :complete
  end

  private

  def redirect_to_checkout *objs, state
    objs.each do |obj|
      if obj.nil?
        return redirect_to fill_in_address_checkout_path if state != :fill_in_address
        return redirect_to fill_in_delivery_path if state != :fill_in_delivery
        return redirect_to fill_in_payment_path if state != :fill_in_payment
        return redirect_to confirm_path if state != :confirm
      end
    end
  end

  def set_current_order
    @current_order = current_user.current_order_in_progress
  end

  def set_addresses
    @billing_address = current_user.billing_address
    @shipping_address = current_user.shipping_address
  end
  def set_delivery
    @delivery = @current_order.delivery
  end
  def set_credit_card
    @credit_card = @current_order.credit_card
  end
  def user_params
    params.require(:user).permit(:billing_address_attributes => [:address, :city, :country_id, :zipcode, :phone, :id],
                                  :shipping_address_attributes => [:address, :city, :country_id, :zipcode, :phone, :id])
  end

end
