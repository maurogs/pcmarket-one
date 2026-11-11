module Api
  module V1
    class CollectionsController < BaseController
      def index
        render json: { data: Collection.active.ordered.map { |c| { slug: c.slug, kind: c.kind, title: c.title, subtitle: c.subtitle, query: c.query } } }
      end

      def show
        collection = Collection.active.find_by!(slug: params[:id])
        listings = paginate(collection.search.results.for_card)
        render json: { collection: { slug: collection.slug, title: collection.title }, data: listings.map { |l| ListingSerializer.card(l) }, meta: @pagination }
      end
    end
  end
end
