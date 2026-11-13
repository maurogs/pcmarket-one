class Users::RegistrationsController < Devise::RegistrationsController
  before_action :check_registrations_open, only: %i[new create]
  rate_limit to: 10, within: 1.hour, only: :create

  def create
    return super if terms_accepted?

    build_resource(sign_up_params)
    resource.validate
    resource.errors.add(:base, :terms_required)
    clean_up_passwords(resource)
    respond_with resource
  end

  protected

  def build_resource(hash = {})
    super
    resource.locale = I18n.locale.to_s
    resource.terms_accepted_at = Time.current if terms_accepted?
    resource.marketing_consent = params.dig(:user, :marketing_consent) == "1"
  end

  private

  def terms_accepted? = params.dig(:user, :terms_accepted) == "1"

  def check_registrations_open
    redirect_to root_path, alert: t("errors.registrations_closed") unless Setting.enabled?(:registrations_open)
  end
end
