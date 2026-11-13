require "test_helper"

class ListingTest < ActiveSupport::TestCase
  test "requires photos and a description to leave draft" do
    listing = Listing.new(user: create_user, category: category, country: spain, title: "RTX 4070", price: 400, status: :published)
    assert_not listing.valid?
    assert listing.errors.key?(:photos)
    assert listing.errors.key?(:description)
  end

  test "rejects spec values that are not filter options" do
    listing = create_listing
    listing.specs = { "gpu_model" => "made_up" }
    assert_not listing.valid?
    assert listing.errors.key?(:specs)
  end

  test "rejects unknown spec keys" do
    listing = create_listing
    listing.specs = { "nonexistent" => "x" }
    assert_not listing.valid?
  end

  test "submit waits for review when approval is required" do
    listing = create_listing(status: :draft)
    listing.submit!
    assert listing.pending_review?
  end

  test "submit publishes directly when approval is disabled" do
    Setting.set(:listing_approval_required, false)
    listing = create_listing(status: :draft)
    listing.submit!
    assert listing.published?
  ensure
    Setting.set(:listing_approval_required, true)
  end

  test "editing a published listing sends it back to review" do
    listing = create_listing
    listing.update!(title: "RTX 4070 Super Founders Edition")
    assert listing.pending_review?
  end

  test "price changes do not require review" do
    listing = create_listing
    listing.update!(price: 420)
    assert listing.published?
  end

  test "reserving the last unit marks the listing as sold" do
    listing = create_listing(quantity: 1)
    listing.reserve_stock!(1)
    assert listing.reload.sold?
    listing.release_stock!(1)
    assert listing.reload.published?
  end

  test "original price must be higher than price" do
    listing = create_listing
    listing.original_price = 300
    assert_not listing.valid?
  end

  test "computes performance score and FPS estimates from benchmark data" do
    listing = create_listing
    assert listing.performance_score.positive?
    game = Game.create!(slug: "fortnite", name: "Fortnite", demand: 60)
    assert_operator listing.estimated_fps(game, "1080p"), :>, listing.estimated_fps(game, "2160p")
  end

  test "vacation mode hides listings" do
    listing = create_listing
    assert_includes Listing.visible, listing
    listing.user.update!(vacation_mode: true)
    assert_not_includes Listing.visible, listing
  end
end
