class CartItem < ApplicationRecord
  belongs_to :cart, touch: true
  belongs_to :listing
  belongs_to :offer, optional: true

  validates :quantity, numericality: { only_integer: true, greater_than: 0 }

  def unit_price_cents
    offer&.usable? && offer.buyer_id == cart.user_id ? offer.amount_cents : listing.price_cents
  end

  def total_cents = unit_price_cents * quantity
end
