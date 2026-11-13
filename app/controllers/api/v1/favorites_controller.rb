module Api
  module V1
    class FavoritesController < BaseController
      before_action :authenticate!

      def index
        listings = paginate(current_user.favorite_listings.publicly_listed.for_card.order("favorites.created_at DESC"))
        render json: { data: listings.map { |l| ListingSerializer.card(l, viewer: current_user) }, meta: @pagination }
      end

      def create
        listing = Listing.find(params[:listing_id].to_i)
        current_user.favorites.find_or_create_by!(listing: listing)
        render json: { favorited: true, favorites_count: listing.reload.favorites_count }, status: :created
      rescue ActiveRecord::RecordNotUnique
        render json: { favorited: true }, status: :ok
      end

      def destroy
        listing = Listing.find(params[:listing_id].to_i)
        current_user.favorites.where(listing: listing).destroy_all
        render json: { favorited: false, favorites_count: listing.reload.favorites_count }
      end
    end
  end
end
