# Everything the listing page needs besides the listing itself.
class ListingDetails
  attr_reader :listing, :viewer

  def initialize(listing, viewer:)
    @listing = listing
    @viewer = viewer
  end

  def seller = listing.user

  def similar
    Listing.visible.where(category_id: listing.category_id).where.not(id: listing.id)
      .order(Arel.sql("ABS(listings.price_cents - #{listing.price_cents.to_i})")).for_card.limit(10)
  end

  def more_from_seller
    seller.listings.visible.where.not(id: listing.id).recent.for_card.limit(10)
  end

  def reviews
    seller.reviews_received.includes(:reviewer, order: :items).recent.limit(5)
  end

  def specs
    listing.category.applicable_filters.filter_map do |definition|
      next if %w[product_labels seller_tags].include?(definition.key)

      label = listing.spec_label(definition.key)
      [ definition.name, label ] if label
    end
  end

  def watchers_count = listing.favorites_count

  def favorited? = viewer.present? && viewer.favorited?(listing)

  def pending_offer
    viewer && Offer.open.find_by(listing: listing, buyer: viewer)
  end

  def accepted_offer
    viewer && Offer.accepted.where(listing: listing, buyer: viewer).order(responded_at: :desc).detect(&:usable?)
  end

  def can_contact? = viewer.nil? || (viewer.id != seller.id && !viewer.blocked?(seller))

  def estimated_arrival
    start = Date.current
    ship = start + listing.handling_days.days
    { ordered: start, ships: ship, arrives: ship + 3.days }
  end

  def games = Game.active.limit(6)
end
