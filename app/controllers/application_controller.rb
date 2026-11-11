class ApplicationController < ActionController::Base
  include Pagy::Method
  include Localization
  include CurrentCart
  include Authorization

  allow_browser versions: :modern, block: -> { render "errors/unsupported_browser", status: :not_acceptable, layout: false }, if: -> { request.format.html? && !Rails.env.test? }

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :enforce_maintenance_mode
  before_action :track_last_seen, if: :user_signed_in?

  rescue_from ActiveRecord::RecordNotFound, ActionController::RoutingError, with: :render_not_found
  rescue_from Authorization::NotAuthorized, Order::NotAllowed, with: :render_forbidden

  helper_method :setting, :feature?

  private

  def setting(name) = Setting.get(name)
  def feature?(name) = Setting.enabled?(name)

  def require_feature!(name)
    render_not_found unless feature?(name)
  end

  def render_not_found
    respond_to do |format|
      format.html { render "errors/not_found", status: :not_found }
      format.any { head :not_found }
    end
  end

  def render_forbidden
    respond_to do |format|
      format.html { redirect_back fallback_location: root_path, alert: t("errors.forbidden") }
      format.any { head :forbidden }
    end
  end

  def enforce_maintenance_mode
    return unless feature?(:maintenance_mode)
    return if current_user&.staff? || devise_controller?

    render "errors/maintenance", status: :service_unavailable, layout: false
  end

  def track_last_seen
    return if current_user.last_seen_at&.after?(10.minutes.ago)

    current_user.update_column(:last_seen_at, Time.current)
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[username first_name last_name terms_accepted marketing_consent])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[username])
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || (resource.staff? ? admin_root_path : root_path)
  end

  def audit!(action, record = nil, details = {})
    AuditLog.record(current_user, action, record, details, ip: request.remote_ip)
  end
end
