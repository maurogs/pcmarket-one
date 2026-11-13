module Authorization
  extend ActiveSupport::Concern

  class NotAuthorized < StandardError; end

  private

  def authorize!(condition)
    raise NotAuthorized unless condition
  end

  def require_staff!
    authenticate_user!
    raise NotAuthorized unless current_user&.staff?
  end

  def require_admin!
    authenticate_user!
    raise NotAuthorized unless current_user&.admin?
  end

  def require_active_user!
    authenticate_user!
    return if current_user.nil? || current_user.can_sell?

    redirect_to root_path, alert: t(current_user.confirmed? ? "errors.account_suspended" : "errors.confirm_email_first")
  end
end
