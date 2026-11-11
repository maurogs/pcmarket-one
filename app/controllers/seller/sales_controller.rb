class Seller::SalesController < Seller::BaseController
  def index
    scope = current_user.sales.recent.includes(:buyer, items: { listing: { photos_attachments: :blob } })
    scope = scope.where(status: params[:status]) if Order.statuses.key?(params[:status])
    @pagy, @orders = pagy(:offset, scope, limit: 20)
  end
end
