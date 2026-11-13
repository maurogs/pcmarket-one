require "application_system_test_case"

class MarketplaceTest < ApplicationSystemTestCase
  setup do
    I18n.locale = I18n.default_locale
    @listing = create_listing
  end

  test "cookie banner stays dismissed once consent is given" do
    visit root_path
    assert_selector "[aria-labelledby=cookie-title]"
    accept_cookies
    assert_no_selector "[aria-labelledby=cookie-title]"

    visit listings_path
    assert_no_selector "[aria-labelledby=cookie-title]"
  end

  test "catalogue filters update results without a full reload" do
    create_listing(title: "GeForce RTX 3060 Ventus", condition: :fair, specs: { "gpu_model" => "rtx_3060" })
    visit category_path(id: "gpus")
    accept_cookies
    assert_text "GeForce RTX 3060 Ventus"

    check I18n.t("listings.conditions.good")
    assert_no_text "GeForce RTX 3060 Ventus"
    assert_text @listing.title
  end

  test "filters open as a full-screen panel on phones" do
    resize_to_phone
    visit listings_path
    accept_cookies
    assert_no_selector "#filters-panel"

    click_on I18n.t("listings.index.filters")
    assert_selector "#filters-panel"
    within("#filters-panel") { click_on I18n.t("layout.close") }
    assert_no_selector "#filters-panel"
  end

  test "signed-in buyer saves a listing to favourites" do
    buyer = create_user
    visit new_user_session_path
    accept_cookies
    fill_in "user[email]", with: buyer.email
    fill_in "user[password]", with: "Password123!"
    find("input[type=submit]").click
    assert_text I18n.t("devise.sessions.signed_in")

    visit listing_path(id: @listing.to_param)
    within("##{ActionView::RecordIdentifier.dom_id(@listing, :favorite)}") { click_on I18n.t("favorites.save") }
    assert_text I18n.t("favorites.saved")
    assert buyer.reload.favorited?(@listing)
  end
end
