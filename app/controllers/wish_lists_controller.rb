class WishListsController < ApplicationController

  before_action :authenticate_user!
  before_action :set_current_wish_list

  def show
  end

  def add_book
    current_book = current_book params[:book_id]
    redirect_to :back, alert: t("wish_list.add_fail") and return if @wish_list.books.include? current_book
    @wish_list.books << current_book
    redirect_to :back, notice: t("wish_list.add_success")
  end

  def remove_book
    current_book = @wish_list.books.find params[:book_id]
    @wish_list.books.destroy current_book
    redirect_to :back, notice: t("wish_list.remove_success")
  end

  private

  def set_current_wish_list
    @wish_list = current_or_guest_user.wish_list
  end

  def current_book id
    Book.find(id)
  end
  def wish_list_params
    params.require(:wish_list).permit(:book_id)
  end
end
