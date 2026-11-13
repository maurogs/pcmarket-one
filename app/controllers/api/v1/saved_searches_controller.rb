module Api
  module V1
    class SavedSearchesController < BaseController
      before_action :authenticate!

      def index
        render json: { data: current_user.saved_searches.order(created_at: :desc).map { |s| s.slice(:id, :name, :query, :notify, :frequency) } }
      end

      def create
        query = ListingSearch.new(params.fetch(:query, {}).permit(*ListingSearch::PERMITTED).to_h).to_query_hash
        saved = current_user.saved_searches.create!(name: params[:name].presence || "Search", query: query, frequency: params[:frequency].presence || :instant)
        render json: { data: saved.slice(:id, :name, :query, :notify, :frequency) }, status: :created
      end

      def destroy
        current_user.saved_searches.find(params[:id]).destroy
        head :no_content
      end
    end
  end
end
