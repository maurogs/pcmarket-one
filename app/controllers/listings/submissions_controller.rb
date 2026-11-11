class Listings::SubmissionsController < ApplicationController
  before_action :require_active_user!

  def create
    listing = Listing.find(params[:listing_id].to_i)
    authorize!(listing.editable_by?(current_user) && (listing.draft? || listing.rejected?))
    listing.submit!(current_user)
    redirect_to listing_path(listing), notice: listing.published? ? t("listings.submitted.published") : t("listings.submitted.pending")
  rescue ActiveRecord::RecordInvalid
    redirect_to edit_listing_path(listing), alert: listing.errors.full_messages.to_sentence
  end
end
