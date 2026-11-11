class Orders::CancellationsController < Orders::BaseController
  def create
    @order.cancel!(current_user, params[:reason].to_s.first(500).presence || t("orders.default_cancel_reason"))
    done(:cancelled)
  end
end
