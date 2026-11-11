class FilterDefinition < ApplicationRecord
  include Translatable
  translates :name

  CACHE_KEY = "filter_definitions/v1".freeze

  enum :kind, { multi_select: 0, single_select: 1, boolean: 2 }, default: :multi_select

  has_many :filter_options, -> { order(:position, :id) }, dependent: :destroy, inverse_of: :filter_definition
  has_many :category_filters, dependent: :delete_all
  has_many :categories, through: :category_filters

  accepts_nested_attributes_for :filter_options, allow_destroy: true, reject_if: ->(attrs) { attrs["value"].blank? }

  validates :key, presence: true, uniqueness: true, format: { with: /\A[a-z0-9_]+\z/ }
  validate { errors.add(:name_translations, :blank) if name_translations.values.all?(&:blank?) }

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:position, :id) }

  after_commit -> { Rails.cache.delete(CACHE_KEY) }

  def self.cached_by_key
    Rails.cache.fetch(CACHE_KEY) { active.includes(:filter_options).index_by(&:key) }
  end

  def option_for(value)
    filter_options.find { |option| option.value == value.to_s }
  end

  def label_for(value)
    option_for(value)&.label || value.to_s.humanize
  end

  def to_param
    key
  end
end
