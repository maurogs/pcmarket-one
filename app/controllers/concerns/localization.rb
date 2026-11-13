module Localization
  extend ActiveSupport::Concern

  COUNTRY_COOKIE = :country

  included do
    around_action :switch_locale
    helper_method :current_country, :enabled_locales
  end

  def default_url_options
    I18n.locale == I18n.default_locale ? { locale: nil } : { locale: I18n.locale }
  end

  private

  def switch_locale(&action)
    I18n.with_locale(resolve_locale, &action)
  end

  def resolve_locale
    requested = params[:locale].presence
    return requested if requested && enabled_locales.include?(requested)

    I18n.default_locale
  end

  def enabled_locales
    @enabled_locales ||= (Setting.get(:locales_enabled) & I18n.available_locales.map(&:to_s)).presence || [ I18n.default_locale.to_s ]
  end

  def current_country
    @current_country ||= begin
      code = cookies[COUNTRY_COOKIE].to_s.upcase
      enabled = Country.enabled_codes
      code = Setting.get(:default_country) unless enabled.include?(code)
      # Unsaved fallback keeps pages working before the reference seeds run.
      Country.find_by(code: code) || Country.default || Country.new(code: "ES", currency: "EUR", default_locale: "es")
    end
  end
end
