class Admin::ListingsController < Admin::BaseController
  before_action :set_listing, except: :index

  def index
    scope = Listing.includes(:user, :category, :country, photos_attachments: :blob)
    scope = scope.where(status: params[:status]) if Listing.statuses.key?(params[:status])
    scope = scope.where(category_id: Category.find(params[:category_id]).descendant_ids) if params[:category_id].present?
    scope = scope.where(country_id: params[:country_id]) if params[:country_id].present?
    scope = scope.where(condition: params[:condition]) if Listing.conditions.key?(params[:condition])
    scope = scope.where(user_id: params[:user_id]) if params[:user_id].present?
    scope = scope.where(featured: true) if params[:featured] == "1"
    if params[:q].present?
      term = "%#{Listing.sanitize_sql_like(params[:q])}%"
      scope = scope.left_joins(:user).where("listings.title ILIKE :t OR listings.id::text = :id OR users.username ILIKE :t", t: term, id: params[:q])
    end
    scope = scope.where(price_cents: (params[:min_price].to_i * 100)..) if params[:min_price].present?
    scope = scope.where(price_cents: ..(params[:max_price].to_i * 100)) if params[:max_price].present?
    @status_counts = Listing.group(:status).count
    @pagy, @listings = paginate(sorted(scope, %w[created_at submitted_at published_at price_cents views_count favorites_count], params[:status] == "pending_review" ? "submitted_at" : "created_at"))
  end

  def show
    @events = @listing.events.includes(:actor).limit(50)
    @reports = @listing.reports.recent
  end

  def edit
    @categories = Category.active.ordered
  end

  def update
    attributes = params.require(:listing).permit(:title, :description, :category_id, :condition, :price, :original_price,
                                                 :quantity, :featured, :brand, :status, labels: [], tags: [], specs: {})
    attributes[:labels] = Array(attributes[:labels]).compact_blank if attributes.key?(:labels)
    if @listing.update(attributes)
      @listing.log!(current_user, "admin_edited")
      audit!("listing.updated", @listing, attributes.to_h.except(:description))
      redirect_to admin_listing_path(@listing), notice: t("admin.flash.updated")
    else
      @categories = Category.active.ordered
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @listing.order_items.exists? ? @listing.archive!(current_user) : @listing.destroy!
    audit!("listing.destroyed", nil, id: @listing.id, title: @listing.title)
    redirect_to admin_listings_path, notice: t("admin.flash.destroyed"), status: :see_other
  end

  private

  def set_listing
    @listing = Listing.find(params[:id].to_i)
  end
end
