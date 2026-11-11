class FilterOption < ApplicationRecord
  include Translatable
  translates :label

  belongs_to :filter_definition, touch: true

  validates :value, presence: true, uniqueness: { scope: :filter_definition_id }, format: { with: /\A[a-z0-9_\-.]+\z/ }

  before_validation { self.value = value.to_s.parameterize(separator: "_") if value.present? && value !~ /\A[a-z0-9_\-.]+\z/ }

  after_commit -> { Rails.cache.delete(FilterDefinition::CACHE_KEY) }

  # Optional GPU/CPU benchmark score used by the PC Finder and performance bars.
  def score = metadata["score"].to_i
  def buyback_cents = metadata["buyback_cents"].to_i

  def label(locale = I18n.locale)
    super.presence || value.to_s.humanize
  end
end
