class Admin::Listings::RejectionsController < Admin::BaseController
  def create
    listing = Listing.find(params[:listing_id].to_i)
    reason = params[:reason].to_s.strip
    return redirect_to(admin_listing_path(listing), alert: t("admin.listings.reason_required")) if reason.blank?

    listing.reject!(current_user, reason)
    audit!("listing.rejected", listing, reason: reason)
    following = Listing.pending_review.order(:submitted_at).first
    redirect_to following ? admin_listing_path(following) : admin_listings_path(status: :pending_review), notice: t("admin.listings.rejected")
  end
end
