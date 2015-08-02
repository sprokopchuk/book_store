class OrderItemsController < ApplicationController

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
    redirect_to :back, notice: 'Book was successfully removed form cart.'
  end
  private

    def order_item_params
      params.require(:order_item).permit(:book_id, :price, :quantity)
    end

end
