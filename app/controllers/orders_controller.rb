class OrdersController < ApplicationController

  before_action :set_current_order, only: [:edit, :update]
  load_and_authorize_resource

  def index
    @orders = current_user.orders
  end

  def show
    @order = current_user.orders.find(params[:id])
  end

  def edit
  end

  def update
    if params[:shopping_cart] && @current_order.update(order_params)
      redirect_to :back, notice: 'Cart was successfully updated.'
    elsif params[:checkout] && @current_order.update(order_params)
      if @current_order.aasm.current_state == :confirm
        order_id = @current_order.id
        @current_order.next_step_checkout!
        redirect_to complete_checkout_path(order_id), notice: "Your order was successfully add in queue"
      else
        @current_order.next_step_checkout!
        redirect_to :action => "#{@current_order.aasm.current_state.to_s}", :controller => "orders/checkout"
      end
    else
      redirect_to :back, notice: 'Something is went wrong.'
    end
  end

  private

  def set_current_order
    @current_order = current_or_guest_user.current_order_in_progress
  end

  def order_params
    params.require(:order).permit(:delivery_id, :credit_card_id, :order_items_attributes => [:id, :quantity])
  end

end
