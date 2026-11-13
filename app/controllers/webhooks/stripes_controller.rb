class Webhooks::StripesController < ActionController::API
  def create
    secret = ENV["STRIPE_WEBHOOK_SECRET"].presence || Rails.application.credentials.dig(:stripe, :webhook_secret)
    return head(:not_found) if secret.blank?

    event = Stripe::Webhook.construct_event(request.raw_post, request.headers["Stripe-Signature"], secret)
    Payments::StripeGateway.handle_event(event)
    head :ok
  rescue JSON::ParserError, Stripe::SignatureVerificationError
    head :bad_request
  end
end
