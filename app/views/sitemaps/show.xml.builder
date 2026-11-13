xml.instruct! :xml, version: "1.0", encoding: "UTF-8"
xml.urlset xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9", "xmlns:xhtml": "http://www.w3.org/1999/xhtml" do
  localized = lambda do |helper, *args, lastmod: nil, priority: "0.5"|
    # One entry per page (default locale) with hreflang alternates keeps us under the 50k URL limit.
    xml.url do
      xml.loc public_send(helper, *args, locale: nil)
      xml.lastmod lastmod.iso8601 if lastmod
      xml.priority priority
      @locales.each do |alternate|
        xml.tag! "xhtml:link", rel: "alternate", hreflang: alternate == "en" ? "en-GB" : alternate,
                               href: public_send(helper, *args, locale: alternate == I18n.default_locale.to_s ? nil : alternate)
      end
    end
  end

  localized.call(:root_url, priority: "1.0")
  localized.call(:listings_url, priority: "0.9")
  localized.call(:trust_url, priority: "0.6")
  localized.call(:sell_info_url, priority: "0.6")
  localized.call(:pc_finder_url, priority: "0.7")
  %w[about help how-it-works fees shipping-guide photo-guide].each { |page| localized.call(:page_url, page, priority: "0.4") }
  LegalPage::SLUGS.each { |slug| localized.call(:legal_page_url, slug.tr("_", "-"), priority: "0.2") }
  @categories.each { |category| localized.call(:category_url, category.slug, lastmod: category.updated_at, priority: "0.8") }
  @collections.each { |collection| localized.call(:collection_url, collection.slug, lastmod: collection.updated_at, priority: "0.6") }
  @stores.each { |store| localized.call(:store_url, store.username, lastmod: store.updated_at, priority: "0.5") }
  @listings.each { |listing| localized.call(:listing_url, listing.to_param, lastmod: listing.updated_at, priority: "0.7") }
end
