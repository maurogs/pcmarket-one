class Orders::ReviewsController < Orders::BaseController
  def new
    authorize!(@order.reviewable_by?(current_user))
    @review = @order.build_review
  end

  def create
    @review = @order.build_review(params.require(:review).permit(:rating, :body).merge(reviewer: current_user))
    if @review.save
      Notification.deliver(@order.seller, :new_review, path: store_reviews_path(@order.seller), rating: @review.rating)
      done(:reviewed)
    else
      render :new, status: :unprocessable_entity
    end
  end
end
