require "test_helper"

class AdminTest < ActionDispatch::IntegrationTest
  test "members cannot access the admin panel" do
    sign_in create_user
    get "/admin"
    assert_response :redirect
  end

  test "admin pages render for staff" do
    create_listing
    sign_in create_user(role: :admin)
    %w[/admin /admin/listings /admin/listings?status=pending_review /admin/users /admin/orders /admin/categories /admin/filter_definitions
       /admin/filter_definitions/new /admin/collections /admin/games /admin/countries /admin/settings /admin/legal_pages /admin/reports
       /admin/reviews /admin/support_tickets /admin/newsletter_subscriptions /admin/buyback_requests /admin/promotions /admin/conversations
       /admin/audit_logs].each do |path|
      get path
      assert_response :success, path
    end
  end

  test "moderators cannot change settings or launch countries" do
    sign_in create_user(role: :moderator)
    patch "/admin/settings", params: { settings: { maintenance_mode: "1" } }
    assert_not Setting.enabled?(:maintenance_mode)
  end

  test "admin toggles feature flags and launches a country" do
    sign_in create_user(role: :admin)
    france = Country.create!(code: "FR", enabled: false, default_locale: "fr")
    patch "/admin/settings", params: { settings: { sell_to_us_enabled: "1" } }
    assert Setting.enabled?(:sell_to_us_enabled)
    patch "/admin/countries/fr", params: { country: { enabled: "true" } }
    assert france.reload.enabled?
    assert AuditLog.where(action: "country.updated").exists?
  end

  test "admin edits filters with options" do
    sign_in create_user(role: :admin)
    post "/admin/filter_definitions", params: { filter_definition: { key: "rgb_color", name_en: "RGB colour", name_es: "Color RGB", category_ids: [ category.id ],
                                                                     filter_options_attributes: { "0" => { value: "red", label_en: "Red", score: "10" } } } }
    definition = FilterDefinition.find_by!(key: "rgb_color")
    assert_equal "Color RGB", definition.name("es")
    assert_equal 10, definition.filter_options.first.score
  end

  test "bulk moderation and rejection notify the seller" do
    listing = create_listing(status: :pending_review)
    sign_in create_user(role: :moderator)
    post "/admin/listings/#{listing.id}/rejection", params: { reason: "Use your own photos" }
    assert listing.reload.rejected?
    assert_equal 1, listing.user.notifications.count
  end
end
