# URL helpers for code that runs outside a request (models, jobs, serializers).
# Routes live under an optional "(:locale)" segment, so positional arguments
# only resolve correctly when the locale key is always present in the options.
class AppRoutes
  include Rails.application.routes.url_helpers

  def self.helpers = @helpers ||= new

  def default_url_options
    locale = I18n.locale == I18n.default_locale ? nil : I18n.locale
    Rails.application.routes.default_url_options.merge(locale: locale)
  end
end
