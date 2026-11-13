class NewsletterMailer < ApplicationMailer
  def confirmation
    @subscription = params[:subscription]
    I18n.with_locale(@subscription.locale) do
      mail to: @subscription.email, subject: t("mailers.newsletter.confirmation.subject", site: Setting.get(:site_name))
    end
  end
end
