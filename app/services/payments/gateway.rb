module Payments
  # Picks Stripe when credentials are configured, otherwise a simulated gateway
  # that confirms payment immediately (development, staging, demos).
  module Gateway
    module_function

    def current
      stripe_key.present? ? StripeGateway.new(stripe_key) : SimulatedGateway.new
    end

    def stripe_key
      ENV["STRIPE_SECRET_KEY"].presence || Rails.application.credentials.dig(:stripe, :secret_key)
    end
  end
end
