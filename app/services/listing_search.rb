# Turns request parameters into a listing scope. Used by the web catalogue, the
# JSON API, saved-search alerts and curated collections, so it only depends on
# plain hashes.
class ListingSearch
  SORTS = %w[best_match newest price_asc price_desc most_watched performance value].freeze
  ARRAY_PARAMS = %i[condition labels tags].freeze
  PERMITTED = [ :q, :category, :min_price, :max_price, :region, :seller, :seller_type, :free_shipping,
               :on_sale, :local_pickup, :sort, :country, :include_sold,
               { condition: [], labels: [], tags: [], f: {} } ].freeze

  attr_reader :params

  def initialize(params = {})
    raw = params.respond_to?(:to_unsafe_h) ? params.to_unsafe_h : params.to_h
    @params = raw.deep_symbolize_keys.slice(*PERMITTED.flat_map { |p| p.is_a?(Hash) ? p.keys : p })
  end

  def category
    return @category if defined?(@category)

    @category = params[:category].presence && Category.active.find_by(slug: params[:category])
  end

  def query = params[:q].to_s.strip.first(100)
  def sort = SORTS.include?(params[:sort]) ? params[:sort] : "best_match"
  def spec_filters = (params[:f] || {}).to_h.transform_keys(&:to_s).transform_values { |v| Array(v).map(&:to_s).compact_blank }.compact_blank
  def list(name) = Array(params[name]).map(&:to_s).compact_blank

  def results
    scope = base_scope
    scope = scope.where(category_id: category.descendant_ids) if category
    scope = apply_text(scope)
    scope = apply_price(scope)
    scope = scope.where(condition: list(:condition) & Listing.conditions.keys) if list(:condition).any?
    scope = scope.where("listings.labels && ARRAY[?]::varchar[]", list(:labels)) if list(:labels).any?
    scope = scope.where("listings.tags && ARRAY[?]::varchar[]", list(:tags)) if list(:tags).any?
    scope = apply_specs(scope)
    scope = apply_flags(scope)
    apply_sort(scope)
  end

  def active_filter_count
    [ query.presence, params[:min_price].presence, params[:max_price].presence, params[:region].presence,
     params[:free_shipping].presence, params[:on_sale].presence, params[:seller_type].presence ].compact.size +
      list(:condition).size + list(:labels).size + list(:tags).size + spec_filters.values.sum(&:size)
  end

  def to_query_hash
    params.except(:sort).compact_blank
  end

  private

  def base_scope
    scope = params[:include_sold].present? ? Listing.publicly_listed.joins(:user).where(users: { status: User.statuses[:active] }) : Listing.visible
    country_codes = Country.enabled_codes
    country_codes &= [ params[:country].to_s.upcase ] if params[:country].present?
    scope.where(country_id: Country.where(code: country_codes).select(:id))
  end

  def apply_text(scope)
    return scope if query.blank?

    matching_sellers = User.where("store_name ILIKE :q OR username ILIKE :q", q: "%#{ActiveRecord::Base.sanitize_sql_like(query)}%").select(:id)
    text_ids = Listing.full_text(query).unscope(:order).select(:id)
    scope.where(id: text_ids).or(scope.where(user_id: matching_sellers))
  end

  def apply_price(scope)
    min = to_cents(params[:min_price])
    max = to_cents(params[:max_price])
    scope = scope.where(price_cents: min..) if min
    scope = scope.where(price_cents: ..max) if max
    scope
  end

  # Values inside one filter are OR-ed, different filters are AND-ed. Each
  # containment check can use the jsonb GIN index.
  def apply_specs(scope)
    known = FilterDefinition.cached_by_key
    spec_filters.each do |key, values|
      next unless known.key?(key)

      clauses = values.first(30).map { |value| Listing.sanitize_sql_array([ "listings.specs @> ?::jsonb", { key => value }.to_json ]) }
      scope = scope.where(clauses.join(" OR "))
    end
    scope
  end

  def apply_flags(scope)
    scope = scope.where(shipping_available: true, shipping_price_cents: 0) if params[:free_shipping].present?
    scope = scope.where(local_pickup: true) if params[:local_pickup].present?
    scope = scope.on_sale if params[:on_sale].present?
    scope = scope.where(region_id: Region.where(code: params[:region]).select(:id)) if params[:region].present?
    if params[:seller].present?
      scope = scope.where(user_id: User.where("lower(username) = ?", params[:seller].to_s.downcase).select(:id))
    end
    scope = scope.where(users: { seller_type: params[:seller_type] }) if User.seller_types.key?(params[:seller_type].to_s)
    scope
  end

  def apply_sort(scope)
    case sort
    when "newest" then scope.order(published_at: :desc, id: :desc)
    when "price_asc" then scope.order(price_cents: :asc, id: :desc)
    when "price_desc" then scope.order(price_cents: :desc, id: :desc)
    when "most_watched" then scope.order(favorites_count: :desc, views_count: :desc, id: :desc)
    when "performance" then scope.order(Arel.sql("listings.performance_score DESC NULLS LAST, listings.id DESC"))
    when "value" then scope.order(Arel.sql("(listings.performance_score::float / NULLIF(listings.price_cents, 0)) DESC NULLS LAST, listings.id DESC"))
    else
      promoted = Setting.enabled?(:promotions_enabled) ? "(listings.promoted_until > now()) DESC NULLS LAST, " : ""
      scope.order(Arel.sql("#{promoted}listings.featured DESC, listings.published_at DESC, listings.id DESC"))
    end
  end

  def to_cents(value)
    return if value.blank?

    amount = value.to_s.tr(",", ".").to_d
    amount.positive? ? (amount * 100).to_i : nil
  rescue ArgumentError
    nil
  end
end
