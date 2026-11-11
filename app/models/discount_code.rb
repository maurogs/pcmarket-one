class DiscountCode < ApplicationRecord
  belongs_to :seller, class_name: "User"

  normalizes :code, with: ->(code) { code.to_s.strip.upcase }

  validates :code, presence: true, format: { with: /\A[A-Z0-9_-]{3,20}\z/ }, uniqueness: { scope: :seller_id }
  validates :percent_off, numericality: { only_integer: true, in: 1..90 }
  validates :max_uses, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true

  def usable?
    active? && (expires_at.nil? || expires_at.future?) && (max_uses.nil? || uses_count < max_uses)
  end

  def discount_for(cents) = (cents * percent_off / 100.0).round
end
