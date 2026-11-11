class ReportsController < ApplicationController
  rate_limit to: 10, within: 1.hour, only: :create

  def new
    @report = Report.new(reportable: find_reportable)
  end

  def create
    @report = Report.new(report_params.merge(reporter: current_user, reportable: find_reportable))
    if @report.save
      redirect_to root_path, notice: t(".success")
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def find_reportable
    type = params[:reportable_type] || params.dig(:report, :reportable_type)
    id = params[:reportable_id] || params.dig(:report, :reportable_id)
    raise ActiveRecord::RecordNotFound unless Report::REPORTABLE_TYPES.include?(type)

    type.constantize.find(id.to_i)
  end

  def report_params
    params.require(:report).permit(:reason, :details, :reporter_email)
  end
end
