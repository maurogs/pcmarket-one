require "test_helper"

class CheckoutTest < ActiveSupport::TestCase
  setup do
    @buyer = create_user
    @address = @buyer.addresses.create!(full_name: "Ana", line1: "Calle 1", city: "Madrid", postal_code: "28001", country_code: "ES")
    @cart = Cart.create!(user: @buyer)
  end

  test "creates one order per seller with totals and reserved stock" do
    first = create_listing(price: 100, shipping_price: 5)
    second = create_listing(price: 200)
    @cart.add(first)
    @cart.add(second)
    result = Checkout.new(cart: @cart, buyer: @buyer, address: @address).call
    assert_equal 2, result.orders.size
    order = result.orders.find { |o| o.seller == first.user }
    assert_equal 10_500, order.total_cents
    assert first.reload.sold?
  end

  test "fails when the item was sold in the meantime" do
    listing = create_listing
    @cart.add(listing)
    listing.reserve_stock!(1)
    assert_raises(Checkout::Error) { Checkout.new(cart: @cart, buyer: @buyer, address: @address).call }
  end

  test "requires an address for shipping" do
    @cart.add(create_listing)
    assert_raises(Checkout::Error) { Checkout.new(cart: @cart, buyer: @buyer, address: nil).call }
  end

  test "applies seller discount codes" do
    listing = create_listing(price: 100)
    listing.user.discount_codes.create!(code: "SAVE10", percent_off: 10)
    @cart.add(listing)
    order = Checkout.new(cart: @cart, buyer: @buyer, address: @address, discount_codes: { listing.user_id => "save10" }).call.orders.first
    assert_equal 9_000, order.total_cents
  end

  test "rolls back everything when one seller fails" do
    good = create_listing
    bad = create_listing(local_pickup: false)
    @cart.add(good)
    @cart.add(bad)
    assert_raises(Checkout::Error) do
      Checkout.new(cart: @cart, buyer: @buyer, address: @address, delivery_methods: { bad.user_id => "pickup" }).call
    end
    assert good.reload.published?
    assert_equal 0, Order.count
  end
end
