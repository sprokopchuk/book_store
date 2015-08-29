class OrdersController < ApplicationController

  before_action :set_current_order, only: [:edit, :update, :index]
  load_and_authorize_resource

  def index
    @orders = current_or_guest_user.orders
  end

  def show
    @order = Order.find(params[:id])
  end

  def edit
  end

  def update
    if @current_order.update(order_params)
      redirect_to :back, notice: t("current_order.update_success")
    else
      redirect_to :back, notice: t("current_order.add_fail")
    end
  end


  private

  def set_current_order
    @current_order = current_or_guest_user.current_order_in_progress
  end

  def order_params
    params.require(:order).permit(:delivery_id, :change_state, :order_items_attributes => [:id, :quantity])
  end

end
