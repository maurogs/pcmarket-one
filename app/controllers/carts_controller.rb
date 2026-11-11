class CartsController < ApplicationController
  def show
    removed = current_cart.prune!
    flash.now[:alert] = t(".removed", titles: removed.to_sentence) if removed.any?
    @groups = current_cart.groups_by_seller
    @recommended = Listing.visible.where.not(id: current_cart.items.select(:listing_id)).order(favorites_count: :desc).for_card.limit(5)
  end
end
