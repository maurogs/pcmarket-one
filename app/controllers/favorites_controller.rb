class FavoritesController < ApplicationController
  before_action :authenticate_user!

  def index
    @pagy, @listings = pagy(:offset, current_user.favorite_listings.publicly_listed.for_card.order("favorites.created_at DESC"), limit: 24)
  end

  def create
    @listing = Listing.find(params[:listing_id].to_i)
    current_user.favorites.find_or_create_by!(listing: @listing)
    respond_toggle
  rescue ActiveRecord::RecordNotUnique
    respond_toggle
  end

  def destroy
    @listing = Listing.find(params[:listing_id].to_i)
    current_user.favorites.where(listing: @listing).destroy_all
    respond_toggle
  end

  private

  def respond_toggle
    @listing.reload
    respond_to do |format|
      format.turbo_stream { render "favorites/toggle" }
      format.html { redirect_back fallback_location: listing_path(@listing) }
    end
  end
end
