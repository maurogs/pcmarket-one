module ListingSerializer
  extend SerializerHelpers
  module_function

  def card(listing, viewer: nil)
    {
      id: listing.id, slug: listing.slug, title: listing.title, status: listing.status, condition: listing.condition,
      price: money(listing.price_cents, listing.currency), original_price: money(listing.original_price_cents, listing.currency),
      discount_percent: listing.discount_percent, free_shipping: listing.free_shipping?, local_pickup: listing.local_pickup,
      image: image_url(listing.cover_photo, :card), category: listing.category&.slug, specs: listing.card_specs,
      performance_score: listing.performance_score, favorites_count: listing.favorites_count,
      favorited: viewer ? viewer.favorited?(listing) : nil, published_at: listing.published_at,
      seller: { username: listing.user.username, name: listing.user.display_name, verified: listing.user.verified?, rating: listing.user.rating_avg.to_f },
      url: routes.listing_url(listing)
    }
  end

  def full(listing, viewer: nil)
    card(listing, viewer: viewer).merge(
      description: listing.description, brand: listing.brand, quantity: listing.quantity, tags: listing.tags, labels: listing.labels,
      specs: listing.specs.to_h { |key, _| [ key, { value: listing.spec(key), label: listing.spec_label(key) } ] },
      photos: listing.photos.map { |photo| { thumb: image_url(photo, :thumb), large: image_url(photo, :large) } },
      shipping: { available: listing.shipping_available, price: money(listing.shipping_price_cents, listing.currency), handling_days: listing.handling_days },
      location: { region: listing.region&.name, city: listing.city, country: listing.country.code },
      allow_offers: listing.allow_offers && Setting.enabled?(:offers_enabled), views_count: listing.views_count,
      rejection_reason: listing.editable_by?(viewer) ? listing.rejection_reason : nil
    )
  end
end
