class Admin::AuditLogsController < Admin::BaseController
  before_action :require_admin!

  def index
    scope = AuditLog.includes(:actor).recent
    scope = scope.where("action ILIKE ?", "#{AuditLog.sanitize_sql_like(params[:q])}%") if params[:q].present?
    @pagy, @logs = paginate(scope, limit: 50)
  end
end
