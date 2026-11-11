# Converts a cart into one order per seller. Stock is reserved with row locks so
# two buyers can never purchase the last unit of the same listing.
class Checkout
  class Error < StandardError; end

  Result = Struct.new(:orders, :reference, keyword_init: true)

  def initialize(cart:, buyer:, address: nil, delivery_methods: {}, discount_codes: {}, note: nil)
    @cart = cart
    @buyer = buyer
    @address = address
    @delivery_methods = delivery_methods.to_h.transform_keys(&:to_s)
    @discount_codes = discount_codes.to_h.transform_keys(&:to_s)
    @note = note.to_s.first(500)
  end

  def call
    raise Error, I18n.t("checkout.errors.disabled") unless Setting.enabled?(:checkout_enabled)
    raise Error, I18n.t("checkout.errors.empty") if @cart.items.empty?

    reference = SecureRandom.uuid
    orders = ActiveRecord::Base.transaction do
      @cart.groups_by_seller.map { |seller, items| build_order(seller, items, reference) }
    end
    Result.new(orders: orders, reference: reference)
  end

  private

  def build_order(seller, items, reference)
    raise Error, I18n.t("checkout.errors.own_listing") if seller == @buyer
    raise Error, I18n.t("checkout.errors.blocked") if Block.between?(seller, @buyer)

    delivery = @delivery_methods.fetch(seller.id.to_s, "shipping")
    delivery = "shipping" unless %w[shipping pickup].include?(delivery)
    raise Error, I18n.t("checkout.errors.address_required") if delivery == "shipping" && @address.nil?

    order = Order.new(buyer: @buyer, seller: seller, checkout_reference: reference, email: @buyer.email,
                      delivery_method: delivery, buyer_note: @note, currency: items.first.listing.currency,
                      shipping_address: delivery == "shipping" ? @address.to_snapshot : {})

    items.each do |item|
      listing = Listing.lock.find(item.listing_id)
      raise Error, I18n.t("checkout.errors.unavailable", title: listing.title) unless listing.available? && listing.quantity >= item.quantity
      raise Error, I18n.t("checkout.errors.no_shipping", title: listing.title) if delivery == "shipping" && !listing.shipping_available?
      raise Error, I18n.t("checkout.errors.no_pickup", title: listing.title) if delivery == "pickup" && !listing.local_pickup?

      unit_price = item.unit_price_cents
      order.items.build(listing: listing, offer: item.offer&.usable? ? item.offer : nil, title: listing.title,
                        unit_price_cents: unit_price, quantity: item.quantity)
      listing.reserve_stock!(item.quantity)
      item.offer.update!(status: :purchased) if item.offer&.usable?
    end

    apply_totals(order, items, delivery, seller)
    order.save!
    order.events.create!(actor: @buyer, to_status: "pending_payment")
    order
  end

  def apply_totals(order, items, delivery, seller)
    order.subtotal_cents = order.items.sum(&:total_cents)
    order.shipping_cents = delivery == "shipping" ? items.map { |i| i.listing.shipping_price_cents }.max.to_i : 0

    code = @discount_codes[seller.id.to_s].presence
    if code && Setting.enabled?(:discount_codes_enabled)
      discount = seller.discount_codes.lock.find_by(code: code.upcase)
      raise Error, I18n.t("checkout.errors.invalid_discount") unless discount&.usable?

      order.discount_code = discount
      order.discount_cents = discount.discount_for(order.subtotal_cents)
      discount.increment!(:uses_count)
    end

    order.total_cents = order.subtotal_cents + order.shipping_cents - order.discount_cents
    order.platform_fee_cents = PlatformFee.for(order.subtotal_cents - order.discount_cents)
  end
end
