class BooksController < ApplicationController
  def index
    @books = Books.all
  end

  def show
    @book = Book.find(params[:id])
  end

  def new
  end

  def edit
  end

  def create
  end

  def update
  end

  def destroy
  end
end
