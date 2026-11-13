# Recurring housekeeping: drop abandoned payments and release funds once the
# buyer protection window closes without a dispute.
class OrderMaintenanceJob < ApplicationJob
  queue_as :default

  UNPAID_TIMEOUT = 1.hour

  def perform
    Order.pending_payment.where(created_at: ..UNPAID_TIMEOUT.ago).find_each do |order|
      order.transition!(:cancelled, note: "payment_timeout", cancel_reason: "payment_timeout")
    end
    Order.delivered.where(protection_ends_at: ..Time.current).find_each do |order|
      order.transition!(:completed, note: "protection_window_closed")
    end
    Promotion.active.where(ends_at: ..Time.current).update_all(status: Promotion.statuses[:expired])
  end
end
