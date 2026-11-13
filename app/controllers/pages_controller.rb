class PagesController < ApplicationController
  PAGES = %w[about trust sell help how_it_works fees shipping_guide photo_guide credits].freeze

  def show
    @page = params[:id].to_s.tr("-", "_")
    raise ActiveRecord::RecordNotFound unless PAGES.include?(@page)

    @recently_sold = Listing.sold.for_card.order(updated_at: :desc).limit(5) if @page == "sell"
    @reviews = Review.visible.where(rating: 5).where.not(body: [ nil, "" ]).includes(:seller).recent.limit(3) if @page == "trust"
    @credits = ImageCredit.order(:source, :creator) if @page == "credits"
    expires_in 10.minutes, public: true unless user_signed_in? || @page == "credits"
    render "pages/#{@page}"
  end
end
