require "test_helper"

class MarketplaceFlowTest < ActionDispatch::IntegrationTest
  test "seller lists an item, moderator approves it, buyer checks out and reviews" do
    seller = create_user
    sign_in seller
    post "/listings", params: { commit_action: "submit", listing: {
      title: "GeForce RTX 3060 12GB", description: "Works perfectly, never mined, comes with the box.", category_id: category.id,
      condition: "good", price: "220", quantity: 1, shipping_available: "1", shipping_price: "5", handling_days: 2,
      region_id: spain.regions.first.id, specs: { gpu_model: "rtx_3060" },
      photos: [ fixture_file_upload("photo.jpg", "image/jpeg") ]
    } }
    listing = Listing.last
    assert listing.pending_review?
    sign_out seller

    moderator = create_user(role: :moderator)
    sign_in moderator
    post "/admin/listings/#{listing.id}/approval"
    assert listing.reload.published?
    sign_out moderator

    buyer = create_user
    buyer.addresses.create!(full_name: "Ana", line1: "Calle 1", city: "Madrid", postal_code: "28001", country_code: "ES")
    sign_in buyer
    post "/cart_items", params: { listing_id: listing.id, buy_now: 1 }
    assert_redirected_to "/checkout"
    post "/checkout", params: { address_id: buyer.addresses.first.id }
    order = Order.last
    assert order.paid?, "simulated gateway should mark the order as paid"
    assert_equal 22_500, order.total_cents
    assert listing.reload.sold?

    sign_out buyer
    sign_in seller
    post "/orders/#{order.number}/shipment", params: { carrier: "Correos", tracking_number: "PQ123" }
    assert order.reload.shipped?
    sign_out seller

    sign_in buyer
    post "/orders/#{order.number}/delivery"
    post "/orders/#{order.number}/acceptance"
    assert order.reload.completed?
    post "/orders/#{order.number}/review", params: { review: { rating: 5, body: "Great" } }
    assert_equal 5, seller.reload.rating_avg.to_i
  end

  test "chat and offers between buyer and seller" do
    listing = create_listing(price: 400)
    buyer = create_user
    sign_in buyer
    post "/listings/#{listing.to_param}/offers", params: { offer: { amount: "360", message: "Would you take 360?" } }
    conversation = Conversation.last
    assert_redirected_to "/conversations/#{conversation.id}"
    post "/conversations/#{conversation.id}/messages", params: { message: { body: "Hello!" } }
    assert_equal 2, conversation.messages.count
    sign_out buyer

    sign_in listing.user
    patch "/offers/#{Offer.last.id}", params: { decision: "accept" }
    assert Offer.last.accepted?
  end

  test "users cannot edit other people's listings or read their conversations" do
    listing = create_listing
    intruder = create_user
    sign_in intruder
    patch "/listings/#{listing.to_param}", params: { listing: { title: "Hacked title" } }
    assert_not_equal "Hacked title", listing.reload.title
    conversation = Conversation.create!(listing: listing, buyer: create_user, seller: listing.user)
    get "/conversations/#{conversation.id}"
    assert_redirected_to root_path
  end

  test "blocked users cannot message each other" do
    listing = create_listing
    buyer = create_user
    Block.create!(blocker: listing.user, blocked: buyer)
    conversation = Conversation.create!(listing: listing, buyer: buyer, seller: listing.user)
    sign_in buyer
    post "/conversations/#{conversation.id}/messages", params: { message: { body: "hi" } }
    assert_equal 0, conversation.messages.count
  end

  test "sign up requires accepting the terms" do
    post "/users", params: { user: { email: "new@example.com", password: "Password123!", password_confirmation: "Password123!", username: "newbie" } }
    assert_nil User.find_by(email: "new@example.com")
    post "/users", params: { user: { email: "new@example.com", password: "Password123!", password_confirmation: "Password123!", username: "newbie", terms_accepted: "1" } }
    assert User.find_by(email: "new@example.com").terms_accepted_at.present?
  end

  test "account deletion anonymises personal data" do
    user = create_user(first_name: "Laura")
    sign_in user
    post "/account/deletion", params: { password: "Password123!" }
    assert user.reload.deleted?
    assert_nil user.first_name
  end
end
