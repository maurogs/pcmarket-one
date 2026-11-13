module OrderSerializer
  extend SerializerHelpers
  module_function

  def call(order, events: false)
    data = {
      number: order.number, status: order.status, delivery_method: order.delivery_method, currency: order.currency,
      subtotal: money(order.subtotal_cents, order.currency), shipping: money(order.shipping_cents, order.currency),
      discount: money(order.discount_cents, order.currency), total: money(order.total_cents, order.currency),
      carrier: order.carrier, tracking_number: order.tracking_number, created_at: order.created_at, paid_at: order.paid_at,
      shipped_at: order.shipped_at, delivered_at: order.delivered_at, protection_ends_at: order.protection_ends_at,
      items: order.items.map { |i| { listing_id: i.listing_id, title: i.title, quantity: i.quantity, unit_price: money(i.unit_price_cents, order.currency) } }
    }
    data[:events] = order.events.map { |e| { from: e.from_status, to: e.to_status, at: e.created_at } } if events
    data
  end
end
