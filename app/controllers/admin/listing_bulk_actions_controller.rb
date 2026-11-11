class Admin::ListingBulkActionsController < Admin::BaseController
  ACTIONS = %w[approve reject pause archive feature unfeature].freeze

  def create
    action = params[:bulk_action].to_s
    ids = Array(params[:listing_ids]).map(&:to_i).first(200)
    return redirect_back(fallback_location: admin_listings_path, alert: t("admin.bulk.invalid")) unless ACTIONS.include?(action) && ids.any?

    count = 0
    Listing.where(id: ids).find_each do |listing|
      count += 1 if apply(action, listing)
    rescue ActiveRecord::RecordInvalid
      next
    end
    audit!("listings.bulk_#{action}", nil, ids: ids)
    redirect_back fallback_location: admin_listings_path, notice: t("admin.bulk.done", count: count)
  end

  private

  def apply(action, listing)
    case action
    when "approve" then listing.pending_review? && listing.approve!(current_user)
    when "reject" then listing.pending_review? && listing.reject!(current_user, params[:reason].presence || t("admin.bulk.default_reason"))
    when "pause" then listing.published? && listing.pause!(current_user)
    when "archive" then listing.archive!(current_user)
    when "feature" then listing.update_columns(featured: true)
    when "unfeature" then listing.update_columns(featured: false)
    end
    true
  end
end
