module SeoHelper
  def seo(title: nil, description: nil, image: nil, canonical: nil, noindex: false, type: "website")
    @seo = { title: title, description: description, image: image, canonical: canonical, noindex: noindex, type: type }
  end

  def json_ld(data)
    (@json_ld ||= []) << data
  end

  def seo_data
    @seo ||= {}
    {
      title: [ @seo[:title].presence, site_name ].compact.join(" · "),
      description: (@seo[:description].presence || t("seo.default_description", site: site_name)).to_s.squish.truncate(160),
      image: @seo[:image].presence || image_url("og-default.png"),
      canonical: @seo[:canonical].presence || canonical_url,
      noindex: @seo[:noindex] || noindex_request?,
      type: @seo[:type] || "website"
    }
  end

  def canonical_url
    allowed = request.query_parameters.slice("page", "q", "category")
    allowed.delete("page") if allowed["page"].to_s == "1"
    base = "#{request.base_url}#{request.path}"
    allowed.any? ? "#{base}?#{allowed.to_query}" : base
  end

  # Faceted URLs would create near-infinite duplicates; keep them out of the index.
  def noindex_request?
    params.keys.intersect?(%w[f min_price max_price condition labels tags sort region seller_type free_shipping on_sale local_pickup])
  end

  def hreflang_links
    return if seo_data[:noindex]

    links = enabled_locales.map do |locale|
      tag.link(rel: "alternate", hreflang: locale == "en" ? "en-GB" : locale, href: locale_url(locale))
    end
    links << tag.link(rel: "alternate", hreflang: "x-default", href: locale_url(I18n.default_locale))
    safe_join(links, "\n")
  end

  def organization_json_ld
    {
      "@context": "https://schema.org",
      "@graph": [
        { "@type": "Organization", "@id": "#{root_url}#org", name: site_name, url: root_url, logo: "#{request.base_url}/icon.png",
          email: Setting.get(:support_email), contactPoint: { "@type": "ContactPoint", contactType: "customer support", email: Setting.get(:support_email), availableLanguage: enabled_locales } },
        { "@type": "WebSite", "@id": "#{root_url}#website", name: site_name, url: root_url, inLanguage: I18n.locale,
          potentialAction: { "@type": "SearchAction", target: "#{listings_url}?q={search_term_string}", "query-input": "required name=search_term_string" } }
      ]
    }
  end

  def breadcrumb_json_ld(crumbs)
    { "@context": "https://schema.org", "@type": "BreadcrumbList",
      itemListElement: crumbs.each_with_index.map { |(name, url), i| { "@type": "ListItem", position: i + 1, name: name, item: url } } }
  end

  def listing_json_ld(listing)
    availability = listing.available? ? "https://schema.org/InStock" : "https://schema.org/SoldOut"
    condition = listing.brand_new? ? "https://schema.org/NewCondition" : (listing.for_parts? ? "https://schema.org/DamagedCondition" : "https://schema.org/UsedCondition")
    data = {
      "@context": "https://schema.org", "@type": "Product", name: listing.title, description: listing.description.truncate(500),
      sku: listing.id.to_s, category: listing.category.name,
      image: listing.photos.first(5).map { |photo| url_for(photo.variant(:large)) },
      offers: { "@type": "Offer", url: listing_url(listing), priceCurrency: listing.currency, price: format("%.2f", listing.price_cents / 100.0),
                availability: availability, itemCondition: condition,
                seller: { "@type": listing.user.business? ? "Organization" : "Person", name: listing.user.display_name } }
    }
    data[:brand] = { "@type": "Brand", name: listing.brand } if listing.brand.present?
    if listing.user.reviews_count.positive?
      data[:aggregateRating] = { "@type": "AggregateRating", ratingValue: listing.user.rating_avg.to_f, reviewCount: listing.user.reviews_count }
    end
    data
  end
end
