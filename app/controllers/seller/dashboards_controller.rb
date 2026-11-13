class Seller::DashboardsController < Seller::BaseController
  def show
    @stats = SellerStats.new(current_user, period: params[:period])
  end
end
