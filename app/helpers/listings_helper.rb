module ListingsHelper
  def condition_label(condition) = t("listings.conditions.#{condition}")

  def listing_image(listing, variant: :card, css: "", eager: false, sizes: nil)
    photo = listing.cover_photo
    if photo&.variable?
      image_tag photo.variant(variant), alt: listing.title, loading: eager ? "eager" : "lazy", decoding: "async",
                fetchpriority: eager ? "high" : nil, class: "h-full w-full object-cover #{css}", sizes: sizes
    else
      tag.div(icon(:package, css: "size-10"), class: "grid h-full w-full place-items-center bg-ink-100 text-ink-400 dark:bg-ink-800 #{css}")
    end
  end

  def price_tag(listing, css: "text-lg")
    safe_join([
      tag.span(money(listing.price_cents, listing.currency), class: "font-bold text-brand-700 dark:text-brand-300 #{css}"),
      (tag.span(money(listing.original_price_cents, listing.currency), class: "ml-1.5 text-xs text-ink-400 line-through") if listing.on_sale?),
      (tag.span("-#{listing.discount_percent}%", class: "ml-1 text-xs font-semibold text-accent-600") if listing.on_sale?)
    ].compact)
  end

  def listing_badge(listing)
    if listing.sold?
      tag.span t("listings.badges.sold"), class: "badge bg-ink-900 text-white"
    elsif listing.on_sale?
      tag.span t("listings.badges.save", percent: listing.discount_percent), class: "badge-accent"
    elsif listing.free_shipping?
      tag.span t("listings.badges.free_shipping"), class: "badge-brand"
    elsif (label = listing.labels.first)
      tag.span FilterDefinition.cached_by_key["product_labels"]&.label_for(label) || label.humanize, class: "badge-brand"
    end
  end

  def spec_value_checked?(search, key, value)
    search.spec_filters.fetch(key, []).include?(value.to_s)
  end

  # Query hash without one filter value, for removable filter chips.
  def search_params_without(search, key, value = nil)
    query = search.params.deep_dup
    if key == :f
      field, option = value
      query[:f] = (query[:f] || {}).to_h.transform_keys(&:to_s)
      query[:f][field] = Array(query[:f][field]).map(&:to_s) - [option.to_s]
      query[:f] = query[:f].compact_blank
    elsif value
      query[key] = Array(query[key]).map(&:to_s) - [value.to_s]
    else
      query.delete(key)
    end
    query.except(:category).compact_blank
  end

  def performance_bar(value, max:, css: "bg-brand-600")
    percent = max.positive? ? (value.to_f / max * 100).clamp(3, 100) : 0
    tag.div(class: "h-1.5 w-full overflow-hidden rounded-full bg-ink-100 dark:bg-ink-800") do
      tag.div(class: "h-full rounded-full #{css}", style: "width: #{percent.round}%")
    end
  end
end
