class BooksController < ApplicationController

  # GET /books
  # GET /books.json
  def index
    @books = Kaminari.paginate_array(Book.all).page(params[:page]).per(6)
  end

  # GET /books/1
  # GET /books/1.json
  def show
    @book = Book.find(params[:id])
  end

  private
    def categories
      @categories = Category.all
    end
end
