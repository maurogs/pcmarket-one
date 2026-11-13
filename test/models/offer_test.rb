require "test_helper"

class OfferTest < ActiveSupport::TestCase
  setup do
    @listing = create_listing(price: 400)
    @buyer = create_user
  end

  test "rejects lowball and over-price offers" do
    assert_not Offer.new(listing: @listing, buyer: @buyer, amount: 100).valid?
    assert_not Offer.new(listing: @listing, buyer: @buyer, amount: 400).valid?
    assert Offer.new(listing: @listing, buyer: @buyer, amount: 350).valid?
  end

  test "sellers cannot offer on their own listing" do
    assert_not Offer.new(listing: @listing, buyer: @listing.user, amount: 350).valid?
  end

  test "only one pending offer per buyer and listing" do
    Offer.create!(listing: @listing, buyer: @buyer, amount: 350)
    assert_not Offer.new(listing: @listing, buyer: @buyer, amount: 360).valid?
  end

  test "accepted offer price applies in the buyer's cart" do
    conversation = Conversation.create!(listing: @listing, buyer: @buyer, seller: @listing.user)
    offer = Offer.create!(listing: @listing, buyer: @buyer, amount: 350, conversation: conversation)
    offer.accept!(@listing.user)
    cart = Cart.create!(user: @buyer)
    item = cart.add(@listing, offer: offer)
    assert_equal 35_000, item.unit_price_cents
  end
end
