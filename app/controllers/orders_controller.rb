class OrdersController < ApplicationController
  before_action :set_order, only: [:show, :edit, :update]
  load_and_authorize_resource

  def index
    @orders = Order.all
  end

  def show
  end

  def edit
  end

  def update
    if @order.update(order_params)
      redirect_to :back, notice: 'Cart was successfully updated.'
    else
      redirect_to :back, notice: 'Something is went wrong.'
    end
  end

  private
    def set_order
      @order = Order.find(params[:id])
    end

    def order_params
      params.require(:order).permit(order_items_attributes: [:id, :quantity])
    end

end
