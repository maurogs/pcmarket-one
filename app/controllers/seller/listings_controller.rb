class Seller::ListingsController < Seller::BaseController
  def index
    @status = Listing.statuses.key?(params[:status]) ? params[:status] : nil
    scope = current_user.listings.includes(:category, photos_attachments: :blob).order(updated_at: :desc)
    scope = scope.where(status: @status) if @status
    scope = scope.where("title ILIKE ?", "%#{Listing.sanitize_sql_like(params[:q])}%") if params[:q].present?
    @counts = current_user.listings.group(:status).count
    @pagy, @listings = pagy(:offset, scope, limit: 25)
  end
end
