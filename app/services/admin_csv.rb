require "csv"

module AdminCsv
  module_function

  def orders(scope)
    CSV.generate do |csv|
      csv << %w[number status buyer seller subtotal shipping discount fee total currency created_at paid_at]
      scope.includes(:buyer, :seller).find_each do |o|
        csv << [o.number, o.status, o.buyer.username, o.seller.username, o.subtotal, o.shipping, o.discount,
                o.platform_fee, o.total, o.currency, o.created_at.iso8601, o.paid_at&.iso8601]
      end
    end
  end

  def subscriptions(scope)
    CSV.generate do |csv|
      csv << %w[email locale confirmed_at]
      scope.find_each { |s| csv << [s.email, s.locale, s.confirmed_at&.iso8601] }
    end
  end
end
