require "test_helper"

class PublicPagesTest < ActionDispatch::IntegrationTest
  setup do
    @listing = create_listing
    Collection.create!(slug: "minimalist", title_translations: { "en" => "Minimalist" }, query: { "category" => "gpus" })
  end

  test "core pages render in every locale" do
    I18n.available_locales.each do |locale|
      prefix = locale == I18n.default_locale ? "" : "/#{locale}"
      [ "/", "/listings", "/c/gpus", "/listings/#{@listing.to_param}", "/stores/#{@listing.user.username}", "/pc-finder",
       "/trust-and-safety", "/sell", "/p/help", "/legal/terms", "/legal/privacy", "/cart", "/users/sign_in", "/users/sign_up",
       "/collections/minimalist", "/support/new" ].each do |path|
        get "#{prefix}#{path}"
        assert_response :success, "#{prefix}#{path}"
      end
    end
  end

  test "catalogue filters and pagination" do
    get "/c/gpus", params: { f: { gpu_model: [ "rtx_4070" ] }, min_price: 100, sort: "price_desc", page: 1 }
    assert_response :success
    assert_select "article", minimum: 1
    assert_select "meta[name=robots][content^=noindex]"
  end

  test "listing page has SEO tags and structured data" do
    get "/listings/#{@listing.to_param}"
    assert_select "link[rel=canonical]"
    assert_select "link[rel=alternate][hreflang=en-GB]"
    assert_select "script[type='application/ld+json']", minimum: 2
    assert_includes response.body, "\"@type\":\"Product\""
  end

  test "outdated slugs redirect permanently to the canonical URL" do
    get "/listings/#{@listing.id}-old-title"
    assert_response :moved_permanently
  end

  test "pending listings are hidden from the public" do
    pending = create_listing(status: :pending_review)
    get "/listings/#{pending.to_param}"
    assert_response :not_found
  end

  test "sitemap and robots" do
    get "/sitemap.xml"
    assert_response :success
    assert_includes response.body, @listing.slug
    get "/robots.txt"
    assert_includes response.body, "Disallow: /admin"
    assert_includes response.body, "Sitemap:"
  end

  test "disabled features return 404" do
    get "/sell-to-us/new"
    assert_response :not_found
  end
end
