class Country < ApplicationRecord
  SUPPORTED = %w[ES FR GB DE IT PT].freeze
  CACHE_KEY = "countries/enabled/v1".freeze

  has_many :regions, -> { order(:position, :name) }, dependent: :destroy
  has_many :listings, dependent: :restrict_with_error

  validates :code, presence: true, uniqueness: true, inclusion: { in: SUPPORTED }
  validates :default_locale, inclusion: { in: I18n.available_locales.map(&:to_s) }
  validates :currency, presence: true
  validates :vat_rate, numericality: { greater_than_or_equal_to: 0 }

  scope :enabled, -> { where(enabled: true) }
  scope :ordered, -> { order(:position, :code) }

  after_commit -> { Rails.cache.delete(CACHE_KEY) }

  def self.enabled_codes
    Rails.cache.fetch(CACHE_KEY) { enabled.ordered.pluck(:code) }
  end

  def self.default
    find_by(code: Setting.get(:default_country)) || enabled.ordered.first || first
  end

  def name(locale = I18n.locale)
    I18n.t("countries.#{code.downcase}", locale: locale)
  end

  def eu?
    code != "GB"
  end

  # Country-specific legal facts (regulators, statutes, company data) used by the legal page templates.
  def legal_value(key)
    legal.fetch(key.to_s) { LegalFacts.for(code).fetch(key.to_s, "") }
  end

  def to_param
    code.downcase
  end
end
