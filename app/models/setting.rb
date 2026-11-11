# Typed key/value store for global options and feature flags managed from the admin panel.
class Setting < ApplicationRecord
  CACHE_KEY = "settings/all/v1".freeze

  # name => [type, default, group]
  DEFINITIONS = {
    site_name:                   [ :string,  "PCMarket", :general ],
    support_email:               [ :string,  "soporte@pcmarket.example", :general ],
    support_phone:               [ :string,  "+34 900 000 000", :general ],
    default_country:             [ :string,  "ES", :general ],
    announcement_enabled:        [ :boolean, true, :general ],
    announcement_link:           [ :string,  "/ofertas", :general ],
    maintenance_mode:            [ :boolean, false, :general ],
    registrations_open:          [ :boolean, true, :general ],
    google_login_enabled:        [ :boolean, false, :general ],

    listing_approval_required:   [ :boolean, true, :listings ],
    max_photos_per_listing:      [ :integer, 12, :listings ],
    max_active_listings_individual: [ :integer, 50, :listings ],
    min_price_cents:             [ :integer, 100, :listings ],
    max_price_cents:             [ :integer, 5_000_000, :listings ],
    offers_enabled:              [ :boolean, true, :listings ],
    offer_expiry_hours:          [ :integer, 48, :listings ],
    min_offer_percent:           [ :integer, 50, :listings ],

    chat_enabled:                [ :boolean, true, :commerce ],
    checkout_enabled:            [ :boolean, true, :commerce ],
    local_pickup_enabled:        [ :boolean, true, :commerce ],
    buyer_protection_days:       [ :integer, 2, :commerce ],
    seller_ship_days:            [ :integer, 3, :commerce ],
    discount_codes_enabled:      [ :boolean, true, :commerce ],

    commissions_enabled:         [ :boolean, false, :monetization ],
    commission_percent:          [ :decimal, 5.0, :monetization ],
    commission_min_cents:        [ :integer, 100, :monetization ],
    promotions_enabled:          [ :boolean, false, :monetization ],
    promotion_price_cents:       [ :integer, 299, :monetization ],
    promotion_days:              [ :integer, 7, :monetization ],

    sell_to_us_enabled:          [ :boolean, false, :features ],
    pc_finder_enabled:           [ :boolean, true, :features ],
    saved_search_alerts_enabled: [ :boolean, true, :features ],
    newsletter_enabled:          [ :boolean, true, :features ],
    reviews_enabled:             [ :boolean, true, :features ],
    dark_mode_enabled:           [ :boolean, true, :features ],

    locales_enabled:             [ :list, %w[es en fr de it pt], :i18n ]
  }.freeze

  GROUPS = DEFINITIONS.values.map(&:last).uniq.freeze

  validates :key, presence: true, uniqueness: true, inclusion: { in: DEFINITIONS.keys.map(&:to_s) }

  after_commit -> { Rails.cache.delete(CACHE_KEY) }

  class << self
    def get(name)
      name = name.to_sym
      definition = DEFINITIONS.fetch(name) { raise ArgumentError, "Unknown setting #{name}" }
      stored = all_values.fetch(name.to_s, :missing)
      stored == :missing ? definition[1] : cast(definition[0], stored)
    end
    alias_method :[], :get

    def enabled?(name) = get(name) == true

    def set(name, value)
      definition = DEFINITIONS.fetch(name.to_sym)
      record = find_or_initialize_by(key: name.to_s)
      record.update!(value: cast(definition[0], value))
    end

    def all_values
      Rails.cache.fetch(CACHE_KEY) { pluck(:key, :value).to_h }
    end

    def cast(type, value)
      case type
      when :boolean then ActiveModel::Type::Boolean.new.cast(value) || false
      when :integer then value.to_i
      when :decimal then value.to_s.tr(",", ".").to_f
      when :list then Array(value).flat_map { |v| v.to_s.split(",") }.map(&:strip).compact_blank
      else value.to_s
      end
    end
  end
end
