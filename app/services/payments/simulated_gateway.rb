module Payments
  class SimulatedGateway
    def name = "simulated"

    # Returns the URL the buyer should be redirected to.
    def start(orders, success_url:, cancel_url:)
      orders.each { |order| order.mark_paid!(reference: "SIM-#{SecureRandom.hex(6)}", provider: name) }
      success_url
    end
  end
end
