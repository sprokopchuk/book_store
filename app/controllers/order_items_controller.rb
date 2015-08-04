class OrderItemsController < ApplicationController

  authorize_resource

  def create
    @order_item = OrderItem.new(order_item_params)
    if current_or_guest_user.current_order_in_progress.add @order_item
      redirect_to :back, notice: 'Book was successfully add to CART.'
    else
      redirect_to :back, notice: 'Book was not add to CART.Something is wrong'
    end
  end

  def destroy
    @item = OrderItem.find(params[:id])
    @item.destroy
    redirect_to :back, notice: 'Book was successfully removed from cart.'
  end

  def destroy_all
    @order_items = current_or_guest_user.current_order_in_progress.order_items.all
    @order_items.destroy_all
    redirect_to :back, notice: 'Cart was successfully emptied'
  end

  private

    def order_item_params
      params.require(:order_item).permit(:book_id, :price, :quantity)
    end

end
