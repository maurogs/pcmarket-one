# Curated, admin-managed groups of listings (themes, gamer profiles, home sections).
class Collection < ApplicationRecord
  include Translatable
  translates :title, :subtitle

  enum :kind, { theme: 0, gamer_profile: 1, home_section: 2, game: 3 }, default: :theme

  has_one_attached :image do |attachable|
    attachable.variant :card, resize_to_fill: [ 640, 360 ], format: :webp, quality: 78
  end

  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-z0-9-]+\z/ }
  validate { errors.add(:title_translations, :blank) if title_translations.values.all?(&:blank?) }

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:position, :id) }

  def search(extra = {})
    ListingSearch.new(query.symbolize_keys.merge(extra))
  end

  def to_param = slug
end
