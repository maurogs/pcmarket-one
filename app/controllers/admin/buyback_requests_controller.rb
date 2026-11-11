class Admin::BuybackRequestsController < Admin::BaseController
  def index
    scope = BuybackRequest.includes(:user, :filter_option).order(created_at: :desc)
    scope = scope.where(status: params[:status]) if BuybackRequest.statuses.key?(params[:status])
    @pagy, @requests = paginate(scope)
  end

  def update
    request_record = BuybackRequest.find(params[:id])
    request_record.update!(status: params[:status]) if BuybackRequest.statuses.key?(params[:status])
    audit!("buyback.#{params[:status]}", request_record)
    redirect_to admin_buyback_requests_path, notice: t("admin.flash.updated")
  end
end
