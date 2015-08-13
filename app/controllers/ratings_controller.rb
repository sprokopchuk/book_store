class RatingsController < ApplicationController

  before_action :current_book, only: :create
  authorize_resource

  def create
    @rating = current_user.ratings.build(rating_params)
    if @rating.save
      redirect_to :back, notice: 'Review was successfully add.'
    else
      redirect_to :back, notice: 'Review was not add.Something is wrong'
    end
  end

  private
  def rating_params
    params.require(:rating).permit(:book_id, :rate, :review)
  end

  def current_book
    @current_book = Book.find(rating_params[:book_id])
  end

end