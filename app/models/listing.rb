class Listing < ApplicationRecord
  include Monetizable
  include ImageValidation
  include PgSearch::Model

  monetize :price, :original_price, :shipping_price

  # Bulk imports (seeds, CSV inventory sync) recompute counters once at the end.
  class_attribute :skip_counter_refresh, default: false

  MAX_TITLE = 120
  REVIEWED_ATTRIBUTES = %w[title description category_id specs brand condition].freeze
  RESOLUTION_FACTORS = { "1080p" => 1.0, "1440p" => 0.68, "2160p" => 0.42 }.freeze

  enum :condition, { brand_new: 0, open_box: 1, like_new: 2, good: 3, fair: 4, for_parts: 5 }, default: :good
  enum :status, { draft: 0, pending_review: 1, published: 2, rejected: 3, paused: 4, sold: 5, archived: 6 }, default: :draft

  belongs_to :user, counter_cache: false
  belongs_to :category, counter_cache: false
  belongs_to :country
  belongs_to :region, optional: true
  belongs_to :reviewer, class_name: "User", optional: true

  has_many_attached :photos do |attachable|
    attachable.variant :thumb, resize_to_fill: [160, 160], format: :webp, quality: 75, preprocessed: true
    attachable.variant :card, resize_to_fill: [480, 400], format: :webp, quality: 78, preprocessed: true
    attachable.variant :large, resize_to_limit: [1400, 1400], format: :webp, quality: 82
  end

  has_many :favorites, dependent: :delete_all
  has_many :events, -> { order(created_at: :desc) }, class_name: "ListingEvent", dependent: :delete_all
  has_many :offers, dependent: :destroy
  has_many :conversations, dependent: :nullify
  has_many :cart_items, dependent: :delete_all
  has_many :order_items, dependent: :restrict_with_error
  has_many :promotions, dependent: :destroy
  has_many :reports, as: :reportable, dependent: :destroy

  pg_search_scope :full_text, against: :title,
    using: { tsearch: { tsvector_column: "searchable", prefix: true, dictionary: "simple" },
             trigram: { only: :title, threshold: 0.2 } },
    ranked_by: ":tsearch + (0.5 * :trigram)"

  normalizes :title, with: ->(title) { title.squish }
  normalizes :tags, with: ->(tags) { Array(tags).map { |t| t.to_s.parameterize }.compact_blank.uniq.first(10) }

  validates :title, presence: true, length: { minimum: 5, maximum: MAX_TITLE }
  validates :description, length: { maximum: 10_000 }
  validates :description, length: { minimum: 20 }, unless: :draft?
  validates :price_cents, numericality: { only_integer: true }
  validate :price_within_limits
  validates :original_price_cents, numericality: { greater_than: :price_cents }, allow_nil: true
  validates :shipping_price_cents, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 50_000 }
  validates :quantity, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 999 }
  validates :handling_days, inclusion: { in: 1..10 }
  validates :postal_code, format: { with: /\A[0-9A-Z \-]{3,10}\z/i }, allow_blank: true
  validate :delivery_method_present
  validate :specs_are_valid
  validate :category_is_leaf
  validate :photos_present, unless: :draft?
  validates_images :photos, max_count: -> { Setting.get(:max_photos_per_listing) }

  before_validation :assign_defaults
  before_save :assign_slug, :compute_performance
  before_update :require_review_on_material_change
  after_commit :refresh_counters, if: -> { saved_change_to_status? || destroyed? }

  scope :visible, -> {
    published.joins(:user).where(users: { status: User.statuses[:active], vacation_mode: false })
  }
  scope :publicly_listed, -> { where(status: %i[published sold]) }
  scope :in_enabled_countries, -> { where(country_id: Country.enabled.select(:id)) }
  scope :on_sale, -> { where("original_price_cents > price_cents") }
  scope :promoted, -> { where("promoted_until > ?", Time.current) }
  scope :with_cover, -> { with_attached_photos }
  scope :recent, -> { order(published_at: :desc, id: :desc) }
  scope :for_card, -> { includes(:user, :category, photos_attachments: :blob) }

  def to_param
    "#{id}-#{slug}"
  end

  def cover_photo
    photos.first
  end

  def available?
    published? && quantity.positive? && user.active? && !user.vacation_mode?
  end

  def on_sale?
    original_price_cents.present? && original_price_cents > price_cents
  end

  def discount_percent
    return 0 unless on_sale?

    (100 - (price_cents * 100.0 / original_price_cents)).round
  end

  def free_shipping?
    shipping_available? && shipping_price_cents.zero?
  end

  def promoted?
    promoted_until.present? && promoted_until.future?
  end

  def editable_by?(someone)
    someone.present? && (someone.id == user_id || someone.staff?)
  end

  def spec(key) = specs[key.to_s]

  def spec_label(key)
    definition = FilterDefinition.cached_by_key[key.to_s]
    value = spec(key)
    return if value.blank?

    definition ? definition.label_for(value) : value
  end

  # Specs shown as chips on listing cards, in admin-defined order.
  def card_specs
    FilterDefinition.cached_by_key.values.select(&:show_on_card).sort_by(&:position)
      .filter_map { |definition| spec_label(definition.key) }.first(4)
  end

  def gpu_score = FilterDefinition.cached_by_key["gpu_model"]&.option_for(spec(:gpu_model))&.score.to_i
  def cpu_score = FilterDefinition.cached_by_key["cpu_model"]&.option_for(spec(:cpu_model))&.score.to_i

  # Rough estimate based on admin-maintained benchmark scores.
  def estimated_fps(game, resolution = "1080p")
    return if gpu_score.zero? || game.nil?

    gpu_fps = gpu_score / game.demand.to_f * 100 * RESOLUTION_FACTORS.fetch(resolution, 1.0)
    cpu_cap = cpu_score.positive? ? cpu_score / 60.0 : gpu_fps
    [gpu_fps, cpu_cap].min.round
  end

  def price_to_performance
    return if performance_score.blank? || price_cents.zero?

    (performance_score / (price_cents / 100.0)).round(1)
  end

  # Moderation / lifecycle -----------------------------------------------------

  def submit!(actor = user)
    return publish!(actor) unless Setting.enabled?(:listing_approval_required) && !user.staff?

    update!(status: :pending_review, submitted_at: Time.current, rejection_reason: nil)
    log!(actor, "submitted")
  end

  def publish!(actor)
    first_publication = published_at.nil?
    update!(status: :published, published_at: published_at || Time.current, submitted_at: submitted_at || Time.current,
            reviewed_at: Time.current, reviewer: actor&.staff? ? actor : reviewer, rejection_reason: nil)
    log!(actor, "published")
    ListingPublishedJob.perform_later(id) if first_publication
  end

  def approve!(moderator)
    publish!(moderator)
    ListingMailer.with(listing: self).approved.deliver_later
    Notification.deliver(user, :listing_approved, path: routes.listing_path(self), title: title)
  end

  def reject!(moderator, reason)
    update!(status: :rejected, rejection_reason: reason, reviewed_at: Time.current, reviewer: moderator)
    log!(moderator, "rejected", reason)
    ListingMailer.with(listing: self).rejected.deliver_later
    Notification.deliver(user, :listing_rejected, path: routes.edit_listing_path(self), title: title)
  end

  def pause!(actor = user)
    update!(status: :paused) && log!(actor, "paused")
  end

  def resume!(actor = user)
    return submit!(actor) if published_at.nil?

    update!(status: :published) && log!(actor, "resumed")
  end

  def archive!(actor = user)
    update_columns(status: Listing.statuses[:archived], updated_at: Time.current)
    log!(actor, "archived")
    refresh_counters
  end

  # Called inside the checkout transaction with the row locked.
  def reserve_stock!(amount)
    raise ActiveRecord::RecordInvalid, self if amount > quantity

    remaining = quantity - amount
    attributes = { quantity: remaining, sold_count: sold_count + amount, updated_at: Time.current }
    attributes[:status] = Listing.statuses[:sold] if remaining.zero?
    update_columns(attributes)
  end

  def release_stock!(amount)
    attributes = { quantity: quantity + amount, sold_count: [sold_count - amount, 0].max, updated_at: Time.current }
    attributes[:status] = Listing.statuses[:published] if sold?
    update_columns(attributes)
  end

  def log!(actor, action, note = nil)
    events.create!(actor: actor, action: action, note: note)
  end

  def increment_views!
    self.class.where(id: id).update_all("views_count = views_count + 1")
  end

  private

  def routes = AppRoutes.helpers

  def assign_defaults
    self.country ||= user&.country || Country.default
    self.currency = country&.currency || "EUR"
    self.allow_offers = false unless Setting.enabled?(:offers_enabled)
    self.specs = specs.to_h.transform_values { |v| v.is_a?(Array) ? v.first.to_s : v.to_s }.compact_blank
  end

  def assign_slug
    self.slug = title.to_s.parameterize.first(80).presence || "listing"
  end

  def compute_performance
    score = (gpu_score * 0.75 + cpu_score * 0.25).round
    self.performance_score = score.positive? ? score : nil
  end

  def require_review_on_material_change
    return unless published? && Setting.enabled?(:listing_approval_required) && !user.staff?
    return unless (changed & REVIEWED_ATTRIBUTES).any? || @photos_changed

    self.status = :pending_review
    self.submitted_at = Time.current
  end

  def refresh_counters
    return if skip_counter_refresh

    user&.refresh_listings_count!
    category && Category.where(id: category.path.map(&:id)).find_each do |node|
      node.update_column(:listings_count, Listing.visible.where(category_id: node.descendant_ids).count)
    end
  end

  def price_within_limits
    return if price_cents.nil?

    min = Setting.get(:min_price_cents)
    max = Setting.get(:max_price_cents)
    errors.add(:price, :greater_than_or_equal_to, count: min / 100.0) if price_cents < min
    errors.add(:price, :less_than_or_equal_to, count: max / 100.0) if price_cents > max
  end

  def delivery_method_present
    errors.add(:base, :delivery_method_required) unless shipping_available? || local_pickup?
  end

  def specs_are_valid
    return if category.nil?

    definitions = category.applicable_filters.index_by(&:key)
    specs.each do |key, value|
      definition = definitions[key]
      if definition.nil?
        errors.add(:specs, :unknown_spec, key: key)
      elsif definition.filter_options.any? && definition.option_for(value).nil?
        errors.add(:specs, :invalid_spec, name: definition.name)
      end
    end
    return if draft?

    definitions.each_value do |definition|
      errors.add(:specs, :missing_spec, name: definition.name) if definition.required? && specs[definition.key].blank?
    end
  end

  def category_is_leaf
    errors.add(:category, :must_be_leaf) if category && !category.leaf?
  end

  def photos_present
    errors.add(:photos, :blank) if photos.none?
  end

  public

  def photos_changed!
    @photos_changed = true
  end
end
