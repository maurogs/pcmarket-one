class Cart < ApplicationRecord
  MAX_ITEMS = 30

  belongs_to :user, optional: true
  has_many :items, -> { order(:created_at) }, class_name: "CartItem", dependent: :delete_all

  has_secure_token :token

  def add(listing, quantity: 1, offer: nil)
    raise ArgumentError, "unavailable" unless listing.available?
    raise ArgumentError, "own_listing" if user && listing.user_id == user.id

    item = items.find_or_initialize_by(listing: listing)
    item.quantity = offer ? 1 : [ item.quantity.to_i + quantity, listing.quantity ].min.clamp(1, listing.quantity)
    item.offer = offer if offer
    item.save!
    item
  end

  def merge!(other)
    return if other.nil? || other == self

    other.items.includes(:listing).find_each do |item|
      add(item.listing, quantity: item.quantity, offer: item.offer) if item.listing.available? && item.listing.user_id != user_id
    rescue ArgumentError
      next
    end
    other.destroy
  end

  def items_count = items.sum(:quantity)

  # Removes items that are no longer purchasable and returns their titles.
  def prune!
    removed = []
    items.includes(:listing).each do |item|
      next if item.listing.available? && item.quantity <= item.listing.quantity

      if item.listing.available?
        item.update!(quantity: item.listing.quantity)
      else
        removed << item.listing.title
        item.destroy
      end
    end
    removed
  end

  def groups_by_seller
    items.includes(:offer, listing: [ :user, { photos_attachments: :blob } ]).group_by { |item| item.listing.user }
  end

  def subtotal_cents = items.includes(:listing, :offer).sum(&:total_cents)
end
