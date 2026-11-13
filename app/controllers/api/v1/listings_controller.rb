module Api
  module V1
    class ListingsController < BaseController
      before_action :authenticate!, only: %i[create update destroy]
      before_action :set_owned_listing, only: %i[update destroy]

      def index
        search = ListingSearch.new(params.permit(*ListingSearch::PERMITTED).to_h)
        listings = paginate(search.results.for_card)
        render json: { data: listings.map { |l| ListingSerializer.card(l, viewer: current_user) }, meta: @pagination }
      end

      def show
        listing = Listing.includes(:category, :user).with_attached_photos.find(params[:id].to_i)
        authorize!(listing.published? || listing.sold? || listing.editable_by?(current_user))
        render json: { data: ListingSerializer.full(listing, viewer: current_user) }
      end

      def create
        authorize!(current_user.can_sell?)
        listing = current_user.listings.create!(listing_params.merge(status: :draft))
        render json: { data: ListingSerializer.full(listing, viewer: current_user) }, status: :created
      end

      def update
        @listing.assign_attributes(listing_params.except(:photos))
        if listing_params[:photos].present?
          @listing.photos.attach(listing_params[:photos])
          @listing.photos_changed!
        end
        @listing.save!
        render json: { data: ListingSerializer.full(@listing, viewer: current_user) }
      end

      def destroy
        @listing.order_items.exists? ? @listing.archive!(current_user) : @listing.destroy!
        head :no_content
      end

      private

      def set_owned_listing
        @listing = Listing.find(params[:id].to_i)
        authorize!(@listing.editable_by?(current_user) && !@listing.sold?)
      end

      def listing_params
        params.require(:listing).permit(:title, :description, :brand, :category_id, :condition, :price, :original_price, :quantity,
                                        :shipping_available, :shipping_price, :local_pickup, :handling_days, :allow_offers,
                                        :region_id, :city, :postal_code, tags: [], specs: {}, photos: [])
      end
    end
  end
end
