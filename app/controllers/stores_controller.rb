class StoresController < ApplicationController
  def show
    @store = User.active.where(deleted_at: nil).where("lower(username) = ?", params[:id].to_s.downcase).first!
    @search = ListingSearch.new(params.permit(*ListingSearch::PERMITTED).to_h.merge(seller: @store.username, include_sold: "1"))
    scope = @search.results.for_card
    scope = scope.reorder(Arel.sql("listings.status = #{Listing.statuses[:sold]}, listings.published_at DESC")) if @search.sort == "best_match"
    @pagy, @listings = pagy(:offset, scope, limit: 24)
    @categories = Category.where(id: @store.listings.publicly_listed.select(:category_id)).ordered
  end
end
