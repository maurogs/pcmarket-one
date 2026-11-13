class Seller::PromotionsController < Seller::BaseController
  before_action { require_feature!(:promotions_enabled) }
  before_action :set_listing

  def new; end

  def create
    days = Setting.get(:promotion_days)
    promotion = @listing.promotions.create!(user: current_user, price_cents: Setting.get(:promotion_price_cents),
                                            starts_at: Time.current, ends_at: days.days.from_now)
    promotion.activate! if Payments::Gateway.current.is_a?(Payments::SimulatedGateway)
    redirect_to seller_listings_path, notice: t(".success")
  end

  private

  def set_listing
    @listing = current_user.listings.published.find(params[:listing_id].to_i)
  end
end
