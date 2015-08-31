class Orders::CheckoutController < ApplicationController

  before_action :authenticate_user!
  before_action except: :complete do |controller|
    set_data controller.action_name
  end
  before_action :set_default_delivery, only: :delivery
  before_action :deliveries, only: :delivery

  def address
  end

  def delivery
    redirect_to_checkout(@checkout_form, :billing_address, :shipping_address)
  end

  def update
    if @checkout_form.save_or_update(checkout_form_params)
      @checkout_form.next_step!
      redirect_to :action => "#{@checkout_form.current_state.to_s}"
    elsif params[:change_state] && @checkout_form.current_state == :confirm
      order_id = @checkout_form.current_order.id
      @checkout_form.next_step!
      redirect_to complete_checkout_path(order_id), notice: t("current_order.in_queue")
    else
      render "#{@checkout_form.current_state.to_s}"
    end

  end

  def payment
    redirect_to_checkout(@checkout_form, :billing_address, :shipping_address, :delivery)
  end

  def confirm
    redirect_to_checkout(@checkout_form, :billing_address, :shipping_address, :delivery, :credit_card)
  end
  def complete
    @order = Order.find(params[:id])
    authorize! :complete, @order
  end

  private

  def redirect_to_checkout checkout_form, *objs
    paths = { address: [:billing_address, :shipping_address],
              delivery: [:delivery],
              payment: [:credit_card]}
    current_order = checkout_form.current_order
    paths.each do |key, value|
      value.each do |v|
        return redirect_to action: "#{key}" if objs.include?(v) && current_order.send(:"#{v}").nil?
      end
    end
  end

  def set_data action_name
    @checkout_form = CheckoutForm.new current_order: current_user.current_order_in_progress
    redirect_to root_path, notice: t("current_order.no_items") unless @checkout_form.current_order.ready_to_checkout?; return if performed?
    @checkout_form.set_current_state :"#{action_name}"
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
