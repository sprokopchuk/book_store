class Orders::CheckoutController < ApplicationController

  before_action :authenticate_user!
  before_action except: [:update, :complete] do |controller|
    set_data controller.action_name
  end
  before_action :set_default_delivery, only: :delivery
  before_action :deliveries, only: :delivery

  def address
  end

  def delivery
  end

  def update
    @checkout_form = CheckoutForm.new current_order: current_user.current_order_in_progress
    if @checkout_form.save_or_update(checkout_form_params)
      @checkout_form.next_step_checkout!
      redirect_to :action => "#{@checkout_form.current_state.to_s}"
    else
      render "#{@checkout_form.current_state.to_s}"
    end
  end

  def payment
  end

  def confirm
  end
  def complete
    @order = Order.find(params[:id])
    authorize! :complete, @order
    @order.next_step_checkout!
    flash.now[:notice] = t("current_order.in_queue")
  end

  private

  def set_data action_name
    @checkout_form = CheckoutForm.new current_order: current_user.current_order_in_progress
    redirect_to root_path, notice: t("current_order.no_items") unless @checkout_form.ready_to_checkout?; return if performed?
    @checkout_form.set_current_state_with_persistence :"#{action_name}"
    redirect_to action: "#{@checkout_form.previous_step}" if @checkout_form.to_previous_step?
  end

  def set_default_delivery
    @default_delivery = current_user.current_order_in_progress.delivery
    @default_delivery ||= Delivery.first
  end

  def deliveries
    @deliveries = Delivery.all
  end

  def checkout_form_params
    params.require(:checkout_form).permit(:use_billing_as_shipping_address,
                                          :billing_address => [:address, :city, :country_id, :zipcode, :phone, :id],
                                          :shipping_address => [:address, :city, :country_id, :zipcode, :phone, :id, :use_billing_address],
                                          :credit_card =>[:number, :cvv, :exp_month, :exp_year, :first_name, :last_name, :id],
                                          :delivery => [:id])
  end

end
