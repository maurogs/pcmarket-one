class Admin::Listings::ApprovalsController < Admin::BaseController
  def create
    listing = Listing.find(params[:listing_id].to_i)
    listing.approve!(current_user)
    audit!("listing.approved", listing)
    redirect_to next_in_queue(listing), notice: t("admin.listings.approved")
  rescue ActiveRecord::RecordInvalid => e
    redirect_to admin_listing_path(listing), alert: e.record.errors.full_messages.to_sentence
  end

  private

  def next_in_queue(listing)
    following = Listing.pending_review.where.not(id: listing.id).order(:submitted_at).first
    following ? admin_listing_path(following) : admin_listings_path(status: :pending_review)
  end
end
