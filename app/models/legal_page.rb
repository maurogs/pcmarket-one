# Optional admin override of the default legal texts shipped in the locale files.
class LegalPage < ApplicationRecord
  SLUGS = %w[terms privacy cookies legal_notice returns buyer_protection seller_terms prohibited_items dsa accessibility].freeze

  validates :slug, inclusion: { in: SLUGS }
  validates :country_code, inclusion: { in: Country::SUPPORTED }
  validates :locale, inclusion: { in: I18n.available_locales.map(&:to_s) }
  validates :title, :body, presence: true
  validates :slug, uniqueness: { scope: %i[country_code locale] }

  scope :published, -> { where(published: true) }
end
