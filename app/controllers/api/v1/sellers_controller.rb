module Api
  module V1
    class SellersController < BaseController
      def show
        seller = User.active.find_by!("lower(username) = ?", params[:id].to_s.downcase)
        listings = paginate(seller.listings.visible.recent.for_card)
        render json: { seller: UserSerializer.public(seller), data: listings.map { |l| ListingSerializer.card(l, viewer: current_user) }, meta: @pagination }
      end
    end
  end
end
