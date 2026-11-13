class Admin::ReportsController < Admin::BaseController
  def index
    scope = Report.includes(:reporter, :reportable).recent
    scope = scope.where(status: params[:status].presence || "open") unless params[:status] == "all"
    scope = scope.where(reason: params[:reason]) if Report.reasons.key?(params[:reason])
    @pagy, @reports = paginate(scope)
  end

  def show
    @report = Report.find(params[:id])
    @report.reviewing! if @report.open?
  end

  def update
    report = Report.find(params[:id])
    status = %w[resolved dismissed].include?(params[:status]) ? params[:status] : "resolved"
    report.close!(current_user, status, params[:resolution_note].to_s)
    if params[:take_down] == "1" && report.reportable.is_a?(Listing)
      report.reportable.reject!(current_user, params[:resolution_note].presence || t("admin.reports.taken_down"))
    end
    audit!("report.#{status}", report, note: params[:resolution_note], take_down: params[:take_down])
    redirect_to admin_reports_path, notice: t("admin.flash.updated")
  end
end
