# Paid highlighting of listings. Disabled until the "promotions_enabled" flag is switched on.
class Promotion < ApplicationRecord
  enum :kind, { highlight: 0 }, default: :highlight
  enum :status, { pending: 0, active: 1, expired: 2, cancelled: 3 }, default: :pending

  belongs_to :listing
  belongs_to :user

  validates :ends_at, comparison: { greater_than: :starts_at }

  def activate!
    transaction do
      update!(status: :active)
      listing.update_columns(promoted_until: [listing.promoted_until, ends_at].compact.max)
    end
  end
end
