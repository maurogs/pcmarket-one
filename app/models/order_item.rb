class OrderItem < ApplicationRecord
  include Monetizable
  monetize :unit_price

  belongs_to :order
  belongs_to :listing
  belongs_to :offer, optional: true

  def total_cents = unit_price_cents * quantity
end
