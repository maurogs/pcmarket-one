class Admin::DashboardsController < Admin::BaseController
  def show
    @stats = AdminStats.new(period: params[:period])
  end
end
