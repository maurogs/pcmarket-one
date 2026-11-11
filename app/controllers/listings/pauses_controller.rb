class Listings::PausesController < ApplicationController
  before_action :require_active_user!
  before_action :set_listing

  def create
    authorize!(@listing.published?)
    @listing.pause!(current_user)
    redirect_back fallback_location: seller_listings_path, notice: t(".success")
  end

  def destroy
    authorize!(@listing.paused?)
    @listing.resume!(current_user)
    redirect_back fallback_location: seller_listings_path, notice: t(".success")
  end

  private

  def set_listing
    @listing = Listing.find(params[:listing_id].to_i)
    authorize!(@listing.editable_by?(current_user))
  end
end
