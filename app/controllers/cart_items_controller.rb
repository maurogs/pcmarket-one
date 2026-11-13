class CartItemsController < ApplicationController
  before_action { require_feature!(:checkout_enabled) }

  def create
    listing = Listing.find(params[:listing_id].to_i)
    offer = current_user && Offer.accepted.find_by(id: params[:offer_id], buyer: current_user, listing: listing)
    current_cart.add(listing, quantity: params[:quantity].to_i.clamp(1, 99), offer: offer)
    redirect_to(params[:buy_now].present? ? checkout_path : cart_path, notice: params[:buy_now].present? ? nil : t(".success"))
  rescue ArgumentError => e
    redirect_back fallback_location: listing_path(listing), alert: t("cart_items.errors.#{e.message}")
  end

  def update
    item = current_cart.items.find(params[:id])
    item.update!(quantity: params[:quantity].to_i.clamp(1, item.listing.quantity)) unless item.offer
    redirect_to cart_path
  end

  def destroy
    current_cart.items.find(params[:id]).destroy
    redirect_to cart_path, notice: t(".success"), status: :see_other
  end
end
