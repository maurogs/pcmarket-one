module SerializerHelpers
  module_function

  def routes = AppRoutes.helpers

  def image_url(attachment, variant = nil)
    return if attachment.blank? || (attachment.respond_to?(:attached?) && !attachment.attached?)

    target = variant && attachment.variable? ? attachment.variant(variant) : attachment
    routes.rails_storage_proxy_url(target)
  rescue ArgumentError
    nil
  end

  def money(cents, currency)
    cents && { cents: cents, amount: (cents / 100.0).round(2), currency: currency }
  end
end
