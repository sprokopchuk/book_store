class RatingsController < ApplicationController

  load_and_authorize_resource

  def create
    @rating.user_id = current_or_guest_user.id
    if @rating.save
      redirect_to :back, notice: t("ratings.add_success")
    else
      redirect_to :back, notice: t("ratings.add_fail")
    end
  end

  private
  def rating_params
    params.require(:rating).permit(:book_id, :rate, :review)
  end

end
