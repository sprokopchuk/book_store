class BooksController < ApplicationController

  before_action :categories, only: [:show, :index]
  before_action :new_order_item, only: :show
  before_action :new_rating, only: :show

  def index
    if params[:category_id]
      @books = Book.where(category_id: params[:category_id]).page(params[:page])
      @current_category = current_category params[:category_id]
    elsif params[:query]
      @books = Book.search params[:query]
    else
      @books = Book.all.page(params[:page])
    end
  end

  def show
    @book = Book.find(params[:id])
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

    def new_rating
      @rating = Rating.new
    end
end
