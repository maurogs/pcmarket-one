module Payments
  # Stripe Checkout. Funds are captured by the platform and released to sellers
  # once the buyer protection window closes (see CompleteOrdersJob).
  class StripeGateway
    def initialize(secret_key)
      @client = Stripe::StripeClient.new(secret_key)
    end

    def name = "stripe"

    # One line per order keeps Stripe totals identical to ours (discounts and shipping included).
    def start(orders, success_url:, cancel_url:)
      line_items = orders.map do |order|
        { quantity: 1, price_data: { currency: order.currency.downcase, unit_amount: order.total_cents,
                                     product_data: { name: I18n.t("checkout.stripe_line", number: order.number, title: order.title).first(250) } } }
      end
      session = @client.v1.checkout.sessions.create(
        mode: "payment", line_items: line_items, customer_email: orders.first.email,
        client_reference_id: orders.first.checkout_reference, locale: I18n.locale.to_s,
        success_url: success_url, cancel_url: cancel_url,
        metadata: { checkout_reference: orders.first.checkout_reference }
      )
      session.url
    end

    def self.handle_event(event)
      return unless event.type == "checkout.session.completed"

      reference = event.data.object.client_reference_id
      Order.pending_payment.where(checkout_reference: reference).find_each do |order|
        order.mark_paid!(reference: event.data.object.payment_intent, provider: "stripe")
      end
    end
  end
end
