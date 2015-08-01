class BooksController < ApplicationController

  before_action :categories, only: [:show, :index, :by_category]
  before_action :new_order_item, only: :show

  def index
    @books = Book.all.page(params[:page])
  end

  def show
    @book = Book.find(params[:id])
  end

  def by_category
    @books = Book.where(category_id: params[:id]).page(params[:page])
    @current_category = current_category params[:id]
  end

  private
    def categories
      @categories = Category.all
    end

    def current_category id
      Category.find(id)
    end

    def new_order_item
      @order_item = OrderItem.new
    end
end
