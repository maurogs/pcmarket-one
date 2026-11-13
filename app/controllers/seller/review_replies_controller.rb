class Seller::ReviewRepliesController < Seller::BaseController
  def update
    review = Review.where(seller: current_user).find(params[:id])
    review.update!(seller_reply: params[:seller_reply].to_s.strip.first(1000).presence)
    redirect_back fallback_location: store_reviews_path(current_user), notice: t(".success")
  end
end
