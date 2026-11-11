class OrderNotifier
  RECIPIENTS = {
    "paid" => %i[buyer seller], "shipped" => %i[buyer], "delivered" => %i[seller], "completed" => %i[seller],
    "cancelled" => %i[buyer seller], "refunded" => %i[buyer seller], "disputed" => %i[seller]
  }.freeze

  def initialize(order)
    @order = order
  end

  def status_changed
    kind = @order.status == "paid" ? "order_paid" : "order_#{@order.status}"
    return unless Notification::KINDS.include?(kind)

    RECIPIENTS.fetch(@order.status, []).each do |role|
      user = @order.public_send(role)
      Notification.deliver(user, kind, path: AppRoutes.helpers.order_path(@order), number: @order.number)
      OrderMailer.with(order: @order, recipient: user).status_changed.deliver_later if user.notify_by_email?(:orders)
    end
  end
end
