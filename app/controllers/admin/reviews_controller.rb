class Admin::ReviewsController < Admin::BaseController
  def index
    scope = Review.includes(:reviewer, :seller).recent
    scope = scope.where(status: params[:status]) if Review.statuses.key?(params[:status])
    scope = scope.where(rating: params[:rating]) if params[:rating].present?
    @pagy, @reviews = paginate(scope)
  end

  def update
    review = Review.find(params[:id])
    review.update!(status: params[:status]) if Review.statuses.key?(params[:status])
    audit!("review.#{params[:status]}", review)
    redirect_back fallback_location: admin_reviews_path, notice: t("admin.flash.updated")
  end
end
