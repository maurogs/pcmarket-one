module Api
  module V1
    class SubmissionsController < BaseController
      before_action :authenticate!

      def create
        listing = Listing.find(params[:listing_id].to_i)
        authorize!(listing.editable_by?(current_user) && (listing.draft? || listing.rejected?))
        listing.submit!(current_user)
        render json: { data: ListingSerializer.full(listing, viewer: current_user) }
      end
    end
  end
end
