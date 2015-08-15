class OrderItemsController < ApplicationController

  authorize_resource

  def create
    @order_item = OrderItem.new(order_item_params)
    if current_or_guest_user.current_order_in_progress.add @order_item
      redirect_to :back, notice: t("order_items.add_success")
    else
      redirect_to :back, notice: t("order_items.add_fail")
    end
  end

  def destroy
    @item = current_or_guest_user.current_order_in_progress.order_items.find(params[:id])
    @item.destroy
    redirect_to :back, notice: t("order_items.destroy_item")
  end

  def destroy_all
    @order_items = current_or_guest_user.current_order_in_progress.order_items
    @order_items.destroy_all
    redirect_to :back, notice: t("order_items.destroy_all_items")
  end

  private

    def order_item_params
      params.require(:order_item).permit(:book_id, :price, :quantity)
    end

end
