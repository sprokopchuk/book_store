class OrderItemsController < ApplicationController

  def create
    @order_item = OrderItem.new(order_item_params)
    if current_or_guest_user.current_order_in_progress.add @order_item
      redirect_to book_path(@order_item.book_id), notice: 'Book was successfully add to CART.'
    else
      redirect_to book_path(@order_item.book_id), notice: 'Book was not add to CART.Something is wrong'
    end
  end

  private
    def order_item_params
      params.require(:order_item).permit(:book_id, :price, :quantity)
    end

end
