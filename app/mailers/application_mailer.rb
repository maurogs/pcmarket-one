class ApplicationMailer < ActionMailer::Base
  default from: -> { "#{Setting.get(:site_name)} <#{ENV.fetch('MAILER_FROM', 'no-reply@pcmarket.example')}>" }
  layout "mailer"
  helper :application, :listings

  # Keeps positional URL arguments working with the optional "(:locale)" route segment.
  def default_url_options
    super.merge(locale: I18n.locale == I18n.default_locale ? nil : I18n.locale)
  end

  private

  def with_locale_for(user, &block)
    I18n.with_locale(user&.locale.presence || I18n.default_locale, &block)
  end
end
