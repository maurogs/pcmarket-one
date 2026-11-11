class Listings::OffersController < ApplicationController
  before_action :require_active_user!
  before_action { require_feature!(:offers_enabled) }
  before_action :set_listing

  def new
    @offer = Offer.new(listing: @listing, amount_cents: (@listing.price_cents * 0.9).round(-2))
  end

  def create
    result = MakeOffer.new(listing: @listing, buyer: current_user, amount: params.dig(:offer, :amount), message: params.dig(:offer, :message)).call
    if result.success?
      redirect_to conversation_path(result.conversation), notice: t(".success")
    else
      @offer = result.offer
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_listing
    @listing = Listing.find(params[:listing_id].to_i)
  end
end
