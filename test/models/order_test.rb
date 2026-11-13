require "test_helper"

class OrderTest < ActiveSupport::TestCase
  setup do
    @seller = create_user
    @buyer = create_user
    @listing = create_listing(user: @seller)
    @order = Order.create!(buyer: @buyer, seller: @seller, checkout_reference: "ref", email: @buyer.email,
                           shipping_address: { "line1" => "Calle 1" }, subtotal_cents: 45_000, total_cents: 45_000)
    @order.items.create!(listing: @listing, title: @listing.title, unit_price_cents: 45_000)
    @listing.reserve_stock!(1)
  end

  test "follows the happy path to completion" do
    @order.mark_paid!(reference: "x", provider: "simulated")
    @order.ship!(@seller, carrier: "Correos", tracking_number: "PQ1")
    @order.confirm_delivery!(@buyer)
    assert @order.protection_ends_at.future?
    @order.accept!(@buyer)
    assert @order.completed?
    assert_equal 1, @seller.reload.sales_count
  end

  test "rejects invalid transitions" do
    assert_raises(Order::InvalidTransition) { @order.transition!(:shipped) }
  end

  test "only the seller can ship" do
    @order.mark_paid!(reference: "x", provider: "simulated")
    assert_raises(Order::NotAllowed) { @order.ship!(@buyer, carrier: "X", tracking_number: "1") }
  end

  test "cancelling releases the stock" do
    @order.cancel!(@buyer, "changed my mind")
    assert @order.cancelled?
    assert @listing.reload.published?
    assert_equal 1, @listing.quantity
  end

  test "buyer can only cancel a paid order after the shipping deadline" do
    @order.mark_paid!(reference: "x", provider: "simulated")
    assert_raises(Order::NotAllowed) { @order.cancel!(@buyer, "too slow") }
    @order.update_column(:paid_at, 10.days.ago)
    @order.cancel!(@buyer, "too slow")
    assert @order.cancelled?
  end

  test "disputes are only possible within the protection window" do
    @order.mark_paid!(reference: "x", provider: "simulated")
    @order.ship!(@seller, carrier: "Correos", tracking_number: "PQ1")
    @order.confirm_delivery!(@buyer)
    @order.update_column(:protection_ends_at, 1.minute.ago)
    assert_raises(Order::NotAllowed) { @order.dispute!(@buyer, "Item does not work at all") }
  end

  test "reviews only after completion and only once" do
    review = Review.new(order: @order, reviewer: @buyer, rating: 5)
    assert_not review.valid?
    @order.update_columns(status: Order.statuses[:completed])
    assert Review.create(order: @order.reload, reviewer: @buyer, rating: 5).persisted?
    assert_not Review.new(order: @order.reload, reviewer: @buyer, rating: 4).valid?
    assert_equal 1, @seller.reload.reviews_count
  end
end
