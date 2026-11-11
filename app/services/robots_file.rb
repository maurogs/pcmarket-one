class RobotsFile
  PRIVATE_PATHS = %w[/admin /account /seller /cart /checkout /orders /conversations /notifications /wishlist
                     /saved_searches /users /api /blocks /reports].freeze

  def initialize(sitemap_url:, allow: true)
    @sitemap_url = sitemap_url
    @allow = allow
  end

  def to_s
    lines = ["User-agent: *"]
    if @allow
      prefixes = [""] + (I18n.available_locales - [I18n.default_locale]).map { |locale| "/#{locale}" }
      lines += prefixes.flat_map { |prefix| PRIVATE_PATHS.map { |path| "Disallow: #{prefix}#{path}" } }
      lines << "Disallow: /*?*sort="
      lines << "Allow: /"
    else
      lines << "Disallow: /"
    end
    (lines + ["", "Sitemap: #{@sitemap_url}"]).join("\n") + "\n"
  end
end
